# -*- coding: utf-8 -*-

"""
Automatically unlock LUKS at boot via SSH, e.g., with dropbear-initramfs.
https://github.com/Ixtalo/SSHUnlockLUKS
"""

import os
import sys
import logging
import socket
from time import sleep
from pathlib import Path
import requests

# https://docs.paramiko.org/en/stable/api/client.html
from paramiko import SSHClient

## https://www.geeksforgeeks.org/read-and-write-toml-files-using-python/
import toml

##******************************************************************************
##******************************************************************************

## Load configuration
with open('ssh_unlock_LUKS.toml', 'r') as f:
    config = toml.load(f)

## Access values from the config
host = config['server']['host']
port = config['server']['port']
ssh_key = config['SSH']['ssh_key']
ssh_user = config['SSH']['ssh_user']
luks_pass = config['LUKS']['luks_pass']
luks_key = config['LUKS']['luks_key']
luks_device = config['LUKS']['luks_device']
luks_name = config['LUKS']['luks_name']
luks_mount = config['LUKS']['luks_mount']

assert host is not None, "Missing configuration!"
assert port is not None, "Missing configuration!"
assert luks_pass is not None or (luks_key is not None and os.path.isfile(luks_key)), "Missing configuration!"
assert luks_device is not None, "Missing configuration!"
assert luks_name is not None, "Missing configuration!"
assert luks_mount is not None, "Missing configuration!"

##******************************************************************************
##******************************************************************************

LOGGING_STREAM = sys.stdout
DEBUG = bool(os.environ.get("DEBUG", "").lower() in ("1", "true", "yes"))

## Check for Python3
if sys.version_info < (3, 0):
    sys.stderr.write("Minimum required version is Python 3.x!\n")
    sys.exit(1)

## Setup logging
logging.basicConfig(
    level=logging.INFO if not DEBUG else logging.DEBUG,
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S")

# ## Check if the remote server is actually in dropbear-initramfs mode
# logging.debug("Trying to connect to %s:%s ...", host, port)
# with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
#     s.settimeout(1)     # 1 seconds timeout
#     s.connect((host, port))
#     data = s.recv(16)   # bufsize should be power of 2
# logging.debug("Remote server data: %s", repr(data))
# if not data.startswith(b"SSH-2.0-dropbear"):
#     logging.warning("No Dropbear-SSH remote endpoint! Nothing to do.")
#     sys.exit(0)

## Check if the remote server is responding
logging.debug("Trying to connect to %s:%s ...", host, port)
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.settimeout(1)     # 1 seconds timeout
    s.connect((host, port))
    data = s.recv(16)   # bufsize should be power of 2
logging.debug("Remote server data: %s", repr(data))
if not data.startswith(b"SSH-2."):
    logging.warning("No SSH remote endpoint! Nothing to do.")
    sys.exit(0)

## Create SSH client
client = SSHClient()

## Load server's public key from file
## => This key check is important to prevent e.g. MITM attacks
# host_keys_filepath = Path(__file__).parent.joinpath("host_keys")
# logging.info("Using host_keys_filepath: %s", host_keys_filepath.resolve())
# client.load_host_keys(str(host_keys_filepath.resolve()))
## Load server's public key from local known_hosts file
client.load_system_host_keys()
logging.info("Establishing SSH connection to %s@%s:%s ...", ssh_user, host, port)
# client.connect(hostname=host, port=port, username=ssh_user, key_filename=os.path.expanduser("~/.ssh/known_hosts"))
client.connect(hostname=host, port=port, username=ssh_user)

logging.info("Open TTY shell ...")
channel = client.invoke_shell()
channel.settimeout(3)
while not channel.recv_ready():
    logging.debug("Waiting for SSH pseudo-terminal to be receive-ready ...")
    sleep(0.5)
channel.recv(1000)
while not channel.send_ready():
    logging.debug("Waiting for SSH pseudo-terminal to be send-ready ...")
    sleep(0.5)

## Decrypt by sending the passphrase to Dropbear
# logging.info("Sending passphrase string plus ENTER/newline ...")
# channel.send(b"%s\n" % luks_pass).encode())

try:
    if luks_pass:
        ## Decrypt by sending the password
        cmd_open = f'echo "{luks_pass}" | sudo cryptsetup open --type luks {luks_device} {luks_name}'
    else:
        ## Decrypt by sending the keyfile
        with open(luks_key, 'r') as f:
            luks_secret = f.read()
        cmd_open = f'echo -n "{luks_secret}" | sudo cryptsetup open --type luks {luks_device} {luks_name} --key-file=- '

    logging.info("Decrypting LUKS container ...")
    stdin, stdout, stderr = client.exec_command(cmd_open)
    stdout_output = stdout.read().decode("utf-8")
    stderr_output = stderr.read().decode("utf-8")
    logging.info("Remote stdout:\n%s", stdout_output)
    logging.info("Remote stderr:\n%s", stderr_output)

    logging.info("Mounting LUKS container ...")
    stdin, stdout, stderr = client.exec_command(f'sudo mount /dev/mapper/{luks_name} {luks_mount}')
    stdout_output = stdout.read().decode("utf-8")
    stderr_output = stderr.read().decode("utf-8")
    logging.info("Remote stdout:\n%s", stdout_output)
    logging.info("Remote stderr:\n%s", stderr_output)

    logging.info("Display mounts ...")
    stdin, stdout, stderr = client.exec_command('mount')
    stdout_output = stdout.read().decode("utf-8")
    stderr_output = stderr.read().decode("utf-8")
    logging.info("Remote stdout:\n%s", stdout_output)
    logging.info("Remote stderr:\n%s", stderr_output)

    logging.info("Waiting 3 seconds (grace time) ...")
    sleep(3)

except paramiko.SSHException as e:
    print(f"Fehler: {e}")

finally:
    logging.debug("Closing SSH connection...")
    client.close()

logging.info("Done.")
