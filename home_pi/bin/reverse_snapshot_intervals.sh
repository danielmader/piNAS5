#!/bin/bash

## https://askubuntu.com/questions/6663/what-happens-if-rsnapshot-rdiff-backup-gets-interrupted-in-the-middle-of-a-tra
## https://unix.stackexchange.com/questions/57484/rename-multiple-directories-decrementing-sequence-number

if [ $# -eq 0 ]; then
    echo -e "\n>>>> Zurückrotieren eines Snapshot-Intervalls (z.B. nach Abbruch) im aktuellen Verzeichnis $(pwd):\nxxx.1 > xxx.0, xxx.2 > xxx.1, etc."
    echo "Usage: $0 <xxx>"
    exit 1
fi

interval=$1

# path=$2
# cd $path

if [ -d "$interval".0 ]; then
    rm -irf "$interval".0
fi

i=0
for x in "$interval".{?,??,???}; do
    if [ -d "$DIRECTORY" ]; then
        echo "$x  >  ${x%.*}.$i"
        mv "$x" "${x%.*}.$i"
        ((++i))
    fi
done
