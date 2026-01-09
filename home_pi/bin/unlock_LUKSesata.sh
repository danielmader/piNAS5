#!/bin/bash

KEYFILE=/mnt/data/.luks_secret

echo -e "\n>>>> Decrypting and mounting LUKS container ..."

## Open LUKS device
# cryptsetup open --type luks /dev/sdc esata --key-file="$KEYFILE" || \
# cryptsetup open --type luks /dev/sdd esata --key-file="$KEYFILE"
if cryptsetup open --type luks /dev/sdc esata --key-file="$KEYFILE"; then
    echo "Erfolgreich an /dev/sdc geöffnet."
elif cryptsetup open --type luks /dev/sdd esata --key-file="$KEYFILE"; then
    echo "Erfolgreich an /dev/sdd geöffnet."
else
    echo "Fehler: Gerät konnte weder auf /dev/sdc noch auf /dev/sdd gefunden werden."
    exit 1
fi

## Mount filesystem
if mount /dev/mapper/esata /mnt/esata; then
    echo "Erfolgreich an /mnt/esata gemountet."
else
    echo "Fehler: Gerät konnte nicht gemountet werden."
    exit 1
fi
