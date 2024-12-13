#!/bin/bash

BASE_DIR="/mnt/esata/rsnapshots/"
BASE_DIR="/srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8/esata/rsnapshots/"
pattern="volume1"

## Moving backup dirs to interval directory:
## > /path/to/rsnapshots/interval.x/volume1/<backup>
## < /path/to/rsnapshots/interval.x/<backup>
find "$BASE_DIR" -type d -name "$pattern" | while read dir; do
    parent_dir=$(dirname "$dir")
    echo -e "\n> $dir"
    echo "< $parent_dir"
    mv "$dir"/* "$parent_dir"/
done

## Deleting empty left-over dirs
find "$BASE_DIR" -type d -name "$pattern" -empty -delete
