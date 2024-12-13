#!/bin/bash

## Prüfen, ob zwei Argumente übergeben wurden
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <directory1> <directory2>"
  exit 1
fi

DIR1="$1"
DIR2="$2"
OUTPUT_FILE="rsync_comparison_$(date +%Y-%m-%d).csv"

## Kopfzeile für die CSV-Datei
echo "path;size_kB_dir1;size_kB_dir2;timestamp_dir1;timestamp_dir2" > "$OUTPUT_FILE"

## rsync im Testlauf-Modus (-n) mit Prüfsummen (--checksum), nur Dateien auflisten, die kopiert würden
rsync -avn --checksum "$DIR1/" "$DIR2/" | grep -vE "^sending incremental file list|^$|^sent|^total size" | while read -r FILE; do
  ## Metadaten der Dateien extrahieren
  FILE1="$DIR1/$FILE"
  FILE2="$DIR2/$FILE"

  ## Sicherstellen, dass es sich um Dateien handelt, die in beiden Verzeichnissen existieren
  if [ -f "$FILE1" ] && [ -f "$FILE2" ]; then
    ## Größe und Zeitstempel von Dateien in beiden Verzeichnissen abrufen
    SIZE1=$(stat --format="%s" "$FILE1")
    TIMESTAMP1=$(stat --format="%Y" "$FILE1")
    TIMESTAMP1_HUMAN=$(date -d @"$TIMESTAMP1" +"%Y-%m-%d")

    SIZE2=$(stat --format="%s" "$FILE2")
    TIMESTAMP2=$(stat --format="%Y" "$FILE2")
    TIMESTAMP2_HUMAN=$(date -d @"$TIMESTAMP2" +"%Y-%m-%d")

    ## Größen in kB umrechnen und CSV-Zeile hinzufügen
    SIZE1_KB=$((SIZE1 / 1024))
    SIZE2_KB=$((SIZE2 / 1024))
    echo "$FILE;$SIZE1_KB;$SIZE2_KB;$TIMESTAMP1_HUMAN;$TIMESTAMP2_HUMAN" >> "$OUTPUT_FILE"
  fi
done

echo "CSV-Datei wurde erstellt: $OUTPUT_FILE"
