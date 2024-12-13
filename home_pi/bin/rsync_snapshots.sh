#!/bin/bash

if [[ "$#" -ne 2 ]]; then
    echo -e "\nRsync-Wrapper mit korrekter Berücksichtigung von Hardlinks, ACLs und erweiterten Attrs'"
    echo "# sudo rsync -aHAX --info=progress2 --delete --stats SRC DST"
    echo -e   "\nAufruf:\n> $(basename "$0")  SRC  DST"
    exit 1
fi

SNAPSHOT_SRC=$1
SNAPSHOT_DST=$2

sudo rsync -aHAX --info=progress2 --delete --stats "$SNAPSHOT_SRC" "$SNAPSHOT_DST"
