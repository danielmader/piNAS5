#!/bin/bash

## Configuration
KEYFILE=/mnt/data/.luks_secret

## UUID
# $ sudo lsblk -o
DISK="db25f167-dffc-47de-98ff-cab6a0e272c9"

echo -e "\n>>>> Decrypting and mounting LUKS container ..."

## Decrypt LUKS device
if cryptsetup open --type luks "/dev/disk/by-uuid/$DISK" esata --key-file="$KEYFILE"; then
    echo "Erfolgreich an /dev/disk/by-uuid/$DISK geöffnet."
else
    echo "Fehler: eSATA-Laufwerk konnte nicht entschlüsselt werden!"
    cryptsetup close esata
    exit 1
fi

## Mount filesystem
if mount /dev/mapper/esata /mnt/esata; then
    echo "Erfolgreich an /mnt/esata gemountet."
else
    echo "Fehler: eSATA-Laufwerk konnte nicht gemountet werden."
    cryptsetup close esata
    exit 1
fi
