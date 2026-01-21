#!/bin/bash

## --- KONFIGURATION ---
# REPO="/mnt/esata/BAK_2025-12-21/restic-repo"
# SECRET="/mnt/data/secret_resticrusticBAK"
REPO="/mnt/esata/restic-repo"
SECRET="/mnt/data/secret_resticrustic"
## Die Pfade, die als separate Snapshots geführt werden sollen:
# SOURCES=("/mnt/asdf" "/mnt/qwer")  # ungültige Pfäde zum Testen
SOURCES=("/home/pi")
SOURCES=("/mnt/data/Music" "/mnt/data/Photos" "/mnt/data/Videos" "/mnt/data/homes" "/home/pi")
## Binary für restic/rustic
RESTICBIN="/home/pi/bin/restic"
RESTICBIN="/home/pi/bin/rustic"

export RESTIC_PASSWORD_FILE="$SECRET"
export RUSTIC_PASSWORD_FILE="$SECRET"

## --- FUNKTIONEN ---
usage() {
    echo "Benutzung: $(basename "$0") [-p SOURCE] [-c PROZENT] [-h]"
    echo ""
    echo "Optionen:"
    echo "  -p SOURCE    Sicherungsverzeichnis"
    echo "  -c PROZENT   führt nach dem Backup einen Integritätscheck aus (z.B. -c 2 für 2%)"
    echo "  -h           zeigt diese Hilfe an"
    echo ""
    echo "Standard-Sicherungsverzeichnisse:"
    for SRC in "${SOURCES[@]}"; do echo "  - $SRC"; done
    exit 0
}

## --- ARGUMENTE PARSEN ---
CHECK_PERCENT=0

## Der Doppelpunkt hinter 'c' bedeutet, dass dieses Flag ein Argument erwartet.
## 'h' hat keinen Doppelpunkt, da es ein reiner Schalter ist.
while getopts "p:c:h" opt; do
    case $opt in
        p)
            SOURCES=($OPTARG)
            # ## Validierung: Pfadangabe?
            # if [[ -z "$OPTARG" ]]; then
            #     SOURCES=$OPTARG
            # else
            #     echo "Fehler: -p erwartet Pfadangabe(n)"
            #     usage
            # fi
            ;;
        c)
            ## Validierung: Ist es eine Zahl?
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
            ## Wird bei unbekannten Flags aufgerufen
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

        if $RESTICBIN -r "$REPO" backup "$SRC" \
                --as-path "/$TARGET_NAME" \
                --exclude-if-present CACHEDIR.TAG \
                --tag "regular" \
                --skip-if-unchanged \
                --ignore-inode; then
            echo $($RESTICBIN -V)
            ## => rustic
        else
            ## => restic
            echo $($RESTICBIN version)
            $RESTICBIN -r "$REPO" backup "$SRC" \
                --exclude-caches \
                --tag "regular" \
                --skip-if-unchanged \
                --ignore-inode
        fi
    else
        echo "WARNUNG: Pfad $SRC nicht gefunden!"
    fi
done

## --- OPTIONALER CHECK ---
if [ "$CHECK_PERCENT" -gt 0 ]; then
    echo "--- Integritätscheck läuft ($CHECK_PERCENT% der Daten)... ---"
    $RESTICBIN -r "$REPO" check --read-data --read-data-subset="${CHECK_PERCENT}%" \
        || $RESTICBIN -r "$REPO" check --read-data-subset="${CHECK_PERCENT}%"
fi

## --- AUFRÄUMEN (KEEP-POLICY) ---
# echo "--- Bereinige alte Snapshots (Keep-Policy) ---"
# $RESTICBIN -r "$REPO" forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# echo "--- Backup Beendet: $(date '+%Y-%m-%d %H:%M:%S') ---"
echo "--- Backup Beendet: $(date) ---"
