#!/bin/bash

##==========================================================
## Initial ideas and workflow description:
## => https://strugglers.net/posts/2025/rethinking-my-backups/
##==========================================================

##----------------------------------------------------------
## Extract timestamps from rsnapshots
## Gemini3 - Thinking Mode
## => https://gemini.google.com/share/5a0c10b7345b
##----------------------------------------------------------
# RSNAPSHOT_ROOT="/mnt/esata/rsnapshots"
# for SNAPSHOT in "${RSNAPSHOT_ROOT}/manual."*; do
#     echo -e "\n## Verarbeite: $SNAPSHOT"
#
#     ## Pfad zum Zielverzeichnis
#     TARGET_DIR="${SNAPSHOT}/homes/mada/.unison/"
#
#     ## 1. Extrahiere den Zeitstempel der neuesten Datei im ISO-Format (YYYY-MM-DD HH:MM)
#     ## grep -v schließt die "total"-Zeile aus, head -n 1 nimmt die oberste Datei
#     TS=$(ls -lt --time-style=long-iso "$TARGET_DIR" | grep -v '^total' | head -n 1 | awk '{print $6" "$7}')
#
#     if [ -n "$TS" ]; then
#         echo "Neuester Zeitstempel gefunden: $TS"
#
#         ## 2. Erstelle/Aktualisiere die Datei ts_manual.x mit diesem Zeitstempel
#         TS_FILE="$RSNAPSHOT_ROOT/ts_$(basename ${SNAPSHOT})_rerun"
#         touch -d "$TS" "${TS_FILE}"
#         echo "Datei ${TS_FILE} wurde aktualisiert."
#     else
#         echo "Warnung: Keine Dateien in $TARGET_DIR gefunden."
#     fi
# done


##----------------------------------------------------------
## Migrate rsnapshots to restic/rustic
## Gemini 3 Thinking Mode
## => https://gemini.google.com/share/26a530897f9c
##
## Requires rustic
## => https://github.com/rustic-rs/rustic
## => https://crates.io/crates/cargo-binstall
## $ curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
## $ ~/.cargo/bin/cargo-binstall rustic-rs
##----------------------------------------------------------

## --- PREPARE ---
swapoff -a

## --- KONFIGURATION ---
#RSNAPSHOT_ROOT="/pfad/zu/rsnapshot"
#RESTIC_REPO="/pfad/zu/restic-repo"
#DATA_SUBDIR="localhost"  # Unterordner im Snapshot (z.B. localhost)
#TARGET_PATH="/"          # Wie der Pfad in restic/rustic erscheinen soll
RSNAPSHOT_ROOT="/mnt/esata/rsnapshots"
RESTIC_REPO="${RSNAPSHOT_ROOT}/restic-repo"

DATA_SUBDIR="homes"
TARGET_PATH="/mnt/data/homes"
DATA_SUBDIR="music"
TARGET_PATH="/mnt/data/Music"
DATA_SUBDIR="Music"
TARGET_PATH="/mnt/data/Music"
DATA_SUBDIR="photo"
TARGET_PATH="/mnt/data/Photos"
DATA_SUBDIR="Photos"
TARGET_PATH="/mnt/data/Photos"
DATA_SUBDIR="Videos"
TARGET_PATH="/mnt/data/Videos"
DATA_SUBDIR="music2sort"
TARGET_PATH="/mnt/data/Music/_music2sort_"

#export RUSTIC_PASSWORD="dein_passwort"
PASSWORD_FILE="${RSNAPSHOT_ROOT}/restic_secret"

## --- MIGRATIONSSCHLEIFE ---
## Wir gehen chronologisch vor: von manual.23 (alt) bis manual.0 (neu)
# for i in {23..23}; do
for i in {22..0}; do
    SNAP_DIR="${RSNAPSHOT_ROOT}/manual.${i}"
    SOURCE_DIR="${SNAP_DIR}/${DATA_SUBDIR}"
    TS_FILE="${RSNAPSHOT_ROOT}/ts_manual.${i}"

    ## Prüfen, ob sowohl der Daten-Ordner als auch die Zeitstempel-Datei existieren
    if [ -d "$SOURCE_DIR" ] && [ -f "$TS_FILE" ]; then
        echo ">>> Verarbeite manual.${i}..."

        ## Zeitstempel der Datei ts_manual.x auslesen
        ## stat -c %y gibt das Datum im Format 'YYYY-MM-DD HH:MM:SS.ns +Offset' aus
        TIMESTAMP=$(stat -c %y "$TS_FILE")

        echo "    Zeitstempel aus $TS_FILE: $TIMESTAMP"

        ## Rustic Backup Befehl
        ## Wir nutzen rustic für das bequeme --as-path Flag
        /home/pi/bin/rustic -r "$RESTIC_REPO" backup "$SOURCE_DIR" \
           -p "$PASSWORD_FILE" \
            --time "$TIMESTAMP" \
            --as-path "$TARGET_PATH" \
            --exclude-if-present CACHEDIR.TAG \
            --tag "migration" \
            --tag "rsnapshot-manual.${i}"

        echo "    ✓ Snapshot manual.${i} erfolgreich importiert."
        echo "-----------------------------------------------------"
    else
        echo "!!! Überspringe manual.${i}:"
        [ ! -d "$SOURCE_DIR" ] && echo "    - Ordner fehlt: $SOURCE_DIR"
        [ ! -f "$TS_FILE" ] && echo "    - Zeitstempel-Datei fehlt: $TS_FILE"
        echo "-----------------------------------------------------"
    fi
done

echo "Migration abgeschlossen."
