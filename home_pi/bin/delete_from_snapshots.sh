#!/bin/bash

## https://chatgpt.com/share/6741a1d7-437c-8005-9f56-16edf8cbd6c4

## Standardwerte
DEBUG=false
SNAPSHOT_DIR="/pfad/zu/rsnapshot-backups/"
SNAPSHOT_DIR="/mnt/esata/rsnapshots/"
#SNAPSHOT_DIR="/srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8/esata/rsnapshots/"

## Hilfefunktion
usage() {
    echo "Verwendung: $0 TARGET_DIR [-s SNAPSHOT_DIR] [--debug]"
    echo "  TARGET_DIR                        Verzeichnis (relativ), das gelöscht werden soll (*OHNE* Backslash)."
    echo "  -s|--snapshot-dir SNAPSHOT_DIR    Basisverzeichnis der Snapshots (Standard: $SNAPSHOT_DIR)."
    echo "  -d|--debug                        Debug-Modus: Nur anzeigen, was gelöscht würde."
    exit 1
}

## Optionen parsen
TARGET_DIR=""
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -s|--snapshot-dir)
            SNAPSHOT_DIR="$2"
            shift 2
            ;;
        -d|--debug)
            DEBUG=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
                shift
            else
                echo "Unbekannte Option oder mehrfaches Zielverzeichnis: $1"
                usage
            fi
            ;;
    esac
done

## Überprüfen, ob das Zielverzeichnis angegeben wurde
if [[ -z "$TARGET_DIR" ]]; then
    echo "Fehler: Zielverzeichnis (-t) muss angegeben werden."
    usage
fi

## Überprüfen, ob das Snapshot-Verzeichnis existiert
if [[ ! -d "$SNAPSHOT_DIR" ]]; then
    echo "Fehler: Snapshot-Verzeichnis $SNAPSHOT_DIR existiert nicht."
    exit 1
fi

## Debug-Modus-Anzeige
if $DEBUG; then
    echo "[DEBUG] Snapshot-Verzeichnis: $SNAPSHOT_DIR"
    echo "[DEBUG] Zielverzeichnis: $TARGET_DIR"
fi

## Durchlaufen aller Snapshot-Verzeichnisse
find "$SNAPSHOT_DIR" -type d -path "*/$TARGET_DIR" | while read -r dir; do
    if $DEBUG; then
        echo "[DEBUG] Lösche Verzeichnis: $dir"
    else
        echo "Lösche Verzeichnis: $dir"
        rm -rf "$dir"
    fi
done

if ! $DEBUG; then
    echo "Löschen abgeschlossen."
else
    echo "[DEBUG] Keine Änderungen vorgenommen (Debug-Modus aktiv)."
fi
