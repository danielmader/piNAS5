#!/bin/bash

## --- KONFIGURATION ---
REPO="/mnt/esata/BAK_2025-12-21/restic-repo"
PASS_FILE="/mnt/data/.luks_secret"
REPO="/mnt/esata/restic-repo"
PASS_FILE="/mnt/data/.restic_secret"
## Die Pfade, die als separate Snapshots geführt werden sollen:
SOURCES=("/mnt/asdf" "/mnt/qwer")
SOURCES=("/home/pi")
SOURCES=("/home/pi" "/mnt/data/homes" "/mnt/data/Music" "/mnt/data/Photos" "/mnt/data/Videos")
## Binary für restic/rustic
RESTIC_BIN="/home/pi/bin/restic"
RESTIC_BIN="/home/pi/bin/rustic"

export RESTIC_PASSWORD_FILE="$PASS_FILE"
export RUSTIC_PASSWORD_FILE="$PASS_FILE"

## --- FUNKTIONEN ---
usage() {
    echo "Benutzung: $(basename "$0") [-c PROZENT] [-h]"
    echo ""
    echo "Optionen:"
    echo "  -c PROZENT   Führt nach dem Backup einen Integritätscheck aus (z.B. -c 2 für 2%)"
    echo "  -h           Zeigt diese Hilfe an"
    echo ""
    echo "Sicherungsverzeichnisse:"
    for SRC in "${SOURCES[@]}"; do echo "  - $SRC"; done
    exit 0
}

## --- ARGUMENTE PARSEN ---
CHECK_PERCENT=0

## Der Doppelpunkt hinter 'c' bedeutet, dass dieses Flag ein Argument erwartet.
## 'h' hat keinen Doppelpunkt, da es ein reiner Schalter ist.
while getopts "c:h" opt; do
    case $opt in
        c)
            # Validierung: Ist es eine Zahl?
            if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                CHECK_PERCENT=$OPTARG
            else
                echo "Fehler: -c erwartet eine Ganzzahl als Prozentangabe."
                usage
            fi
            ;;
        h)
            usage
            ;;
        \?)
            # Wird bei unbekannten Flags aufgerufen
            usage
            ;;
    esac
done

## --- BACKUP VORGANG ---
#echo "--- Backup Start: $(date '+%Y-%m-%d %H:%M:%S') ---"
echo "--- Backup Start: $(date) ---"
for SRC in "${SOURCES[@]}"; do
    if [ -d "$SRC" ]; then
        echo "Sichere: $SRC..."
        ## Wir nutzen --as-path, um die Struktur deiner rsnapshot-Migration (/) beizubehalten
        ## Falls du die Originalpfade im Repo willst, entferne --as-path
        TARGET_NAME=$(basename "$SRC")
        TARGET_NAME=$SRC

        $RESTIC_BIN -r "$REPO" backup "$SRC" \
            --as-path "/$TARGET_NAME" \
            --exclude-if-present CACHEDIR.TAG \
            --tag "regular" \
            --skip-if-unchanged
    else
        echo "WARNUNG: Pfad $SRC nicht gefunden!"
    fi
done

## --- OPTIONALER CHECK ---
if [ "$CHECK_PERCENT" -gt 0 ]; then
    echo "--- Integritätscheck läuft ($CHECK_PERCENT% der Daten)... ---"
    $RESTIC_BIN -r "$REPO" check --read-data-subset="${CHECK_PERCENT}%"
fi

## --- AUFRÄUMEN (KEEP-POLICY) ---
# echo "--- Bereinige alte Snapshots (Keep-Policy) ---"
# $RESTIC_BIN -r "$REPO" forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# echo "--- Backup Beendet: $(date '+%Y-%m-%d %H:%M:%S') ---"
echo "--- Backup Beendet: $(date) ---"
