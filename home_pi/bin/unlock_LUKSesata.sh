#!/bin/bash

KEYFILE=/mnt/data/.secret

## Open LUKS device
echo -e "\n>>>> Decrypting LUKS container ..."
sudo cryptsetup open --type luks  /dev/sdc esata  --key-file=$KEYFILE

## Mount filesystem
sudo mount /dev/mapper/esata /mnt/esata
