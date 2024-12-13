#!/bin/bash

## https://www.synology-forum.de/threads/script-verschluesselten-ordner-via-keyfile-key-entschluesseln.48569/page-2#post-1060287

## Eine Variable, die den Namen des lokalen Servers (DiskStation) enthaelt
server="server"

## Adresse/Pfad des SMB-Ordners, der auf einem anderen Server liegt. Dieser Server kann im LAN oder in der Cloud sein
remotepath="//192.168.nnn.nnn/share/folder"

## Adresse/Pfad, wo "remotepath" lokal eingebunden werden soll
mountpoint="/mnt/crypt1/"

## der Ordner, der den lokalen Teil des Passwords enthaelt
local="/home/pi/"

part1=".secret1"
part2=".secret2"

## Username und Passwort fuer den Nutzer des einzubindenden Servers - SMB/CIFS-Verbindung
username="username"
password="password"

## das Share wird lokal unter "mountpoint" eingebunden
mount -t cifs -o vers=3.0,username="$username",password="$password" "$remotepath" "$mountpoint"

## Namen der Ordner, die entschluesselt werden sollen
folders=(share1 share2)
for i in ${folders[@]}; do
    pwremotepart1=$(<$mountpoint${server}${i}$part1)
    pwlocalpart2=$(<$local${server}${i}$part2)
    pw="$pwremotepart1$pwlocalpart2"
    ## Synology encrypted shares
    /usr/syno/sbin/synoshare --enc_mount $i $pw
done

### Der Ordner "remotepath", der unter "mountpoint" eingehaengt war, wird wieder ausgehangen
umount $mountpoint
