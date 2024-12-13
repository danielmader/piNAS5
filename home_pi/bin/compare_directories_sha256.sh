#!/bin/bash

## Prüfen, ob zwei Argumente übergeben wurden
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <directory1> <directory2>"
  exit 1
fi

## Verzeichnispfade
DIR1="$1"
DIR2="$2"

## Prüfen, ob beide Verzeichnisse existieren
if [ ! -d "$DIR1" ]; then
  echo "Error: Directory '$DIR1' does not exist."
  exit 1
fi

if [ ! -d "$DIR2" ]; then
  echo "Error: Directory '$DIR2' does not exist."
  exit 1
fi

## Temporäre Dateien für die Hash-Listen
HASHES1="/tmp/hashes_dir1_$(date +%Y-%m-%d).txt"
HASHES2="/tmp/hashes_dir2_$(date +%Y-%m-%d).txt"

## Alte Hash-Dateien löschen, falls vorhanden
rm -f "$HASHES1" "$HASHES2"

## Dateien, die in beiden Verzeichnissen existieren, finden
COMMON_FILES=$(comm -12 <(find "$DIR1" -type f -printf "%P\n" | sort) \
           <(find "$DIR2" -type f -printf "%P\n" | sort))

## SHA-256-Hashes für die gemeinsamen Dateien berechnen
for FILE in $COMMON_FILES; do
  if [ -f "$DIR1/$FILE" ] && [ -f "$DIR2/$FILE" ]; then
    # echo "Comparing $FILE..."
    sha256sum "$DIR1/$FILE" >> "$HASHES1"
    sha256sum "$DIR2/$FILE" >> "$HASHES2"
    # b2sum "$DIR1/$FILE" >> "$HASHES1"
    # b2sum "$DIR2/$FILE" >> "$HASHES2"
  fi
done

## Hash-Listen ausgeben
echo "Hashes for files in $DIR1 saved to: $HASHES1"
echo "Hashes for files in $DIR2 saved to: $HASHES2"

## Diff-Vergleich der Hash-Listen
echo "Comparing hashes with diff..."
diff "$HASHES1" "$HASHES2"
