#!/bin/bash

# https://drive.google.com/file/d/<FILEID>/view?usp=sharing
# https://drive.google.com/uc?id=<FILEID>&export=download

FILEID=1HPepbUIkCD6b3kPvYDQSJT74ED2ZEPec
SECRET1="/home/pi/.secret1"

## Save to file ----------------------------------------------------------------
# wget "https://drive.google.com/uc?id=$FILEID&export=download" -O secret2
# cat secret1 secret2 > secret12
# cat secret12

## Save as variable ------------------------------------------------------------
echo -e "\n>>>> Downloading key part ..."
SECRET2=$(wget "https://drive.google.com/uc?id=$FILEID&export=download" -O-)
# echo "$SECRET2"

## Set internal file separator to handle newlines correctly (needed for echo w/o double quotes)
# IFS=
# echo $SECRET2

## Concatenate to file
# echo "$SECRET2" | cat secret1 - > secret12
# cat secret12

echo -e "\n>>>> Assembling full key ..."
## Concatenate as variable using a subshell $()
SECRET12=$(echo "$SECRET2" | cat "$SECRET1" -)
## Concatenate as variable using process substitution <(...)
SECRET12=$(cat "$SECRET1" <(echo "$SECRET2"))
# echo "$SECRET12"
## Save to file for comparison
# echo "$SECRET12" > secret

## Open LUKS devices
echo -e "\n>>>> Decrypting LUKS containers ..."
# /usr/sbin/cryptsetup open --type luks  /dev/sda data1  --key-file=cryptkey
# /usr/sbin/cryptsetup open --type luks  /dev/sdb data2  --key-file=cryptkey
echo "$SECRET12" | /usr/sbin/cryptsetup open --type luks  /dev/sda data1  --key-file=-
echo "$SECRET12" | /usr/sbin/cryptsetup open --type luks  /dev/sdb data2  --key-file=-

## Mount RAID
/usr/bin/mount /srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8
