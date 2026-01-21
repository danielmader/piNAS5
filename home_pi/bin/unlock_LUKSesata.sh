#!/bin/bash

## Configuration
KEYFILE=/mnt/data/secret_LUKSsata

## UUID
# $ sudo lsblk -o
# $ blkid
DISK="b0335d2a-328e-4a74-a25b-65a4db42b5d0"

echo -e "\n>>>> Entschlüssele LUKS Container..."

## Decrypt LUKS device ---------------------------------------------------------
if cryptsetup luksOpen --type luks "/dev/disk/by-uuid/$DISK" esata --key-file="$KEYFILE"; then
    echo "LUKS-Container erfolgreich geöffnet."
else
    echo "Fehler: LUKS-Container konnte nicht gefunden/entschlüsselt werden!"
    cryptsetup close esata
    exit 1
fi

## Mount filesystem ------------------------------------------------------------
if mount /dev/mapper/esata /mnt/esata; then
    echo "LUKS-Container erfolgreich an /mnt/esata gemountet."
else
    echo "Fehler: LUKS-Container konnte nicht gemountet werden."
    cryptsetup close esata
    exit 1
fi
