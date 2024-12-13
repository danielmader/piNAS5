#!/bin/bash

## Ausgangspfad definieren
BASE_DIR="/path/to/rsnapshots"
BASE_DIR="/mnt/esata/rsnapshots"
BASE_DIR="/srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8/esata/rsnapshots"
pattern_old="volume1"
pattern_new="manual"

## Sicherstellen, dass das Skript mit root-Berechtigungen läuft, falls notwendig
if [[ $EUID -ne 0 ]]; then
   echo "Dieses Skript muss mit root-Berechtigungen ausgeführt werden." >&2
   exit 1
fi

for dir in "$BASE_DIR/$pattern_old".*; do
    new_name=$(echo "$dir" | sed "s/$pattern_old/$pattern_new/")
    echo -e "\n> $dir"
    echo "< $new_name"
    mv "$dir" "$new_name"
done
