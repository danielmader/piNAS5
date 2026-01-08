#!/bin/bash

cat << EOF

>> https://gemini.google.com/share/f358f66c74c3 <<

Methode 1: Der "Trockenlauf" mit rsync (Empfohlen)
--------------------------------------------------
## Snapshot einhängen: Erstelle einen Mount-Punkt und mounte das Repository:
mkdir /tmp/restic-check
rustic -r "/pfad/zu/restic-repo" mount /tmp/restic-check &

## Vergleich ausführen: Wir vergleichen nun den rsnapshot-Ordner mit dem Pfad im Mount-Verzeichnis:
## Pfad zum neuesten Snapshot im Mount finden (meistens unter 'snapshots/latest/...')
MOUNTED_SNAPSHOT="/tmp/restic-check/snapshots/latest"
## rsync im Dry-Run Modus (-n)
rsync -nav --delete "/pfad/zu/rsnapshot/manual.0/localhost/" "$MOUNTED_SNAPSHOT/"

## Ergebnis interpretieren:
## Wenn die Liste leer ist (bis auf Header/Footer): Die Daten sind identisch.
## Werden Dateien aufgelistet: Diese Dateien unterscheiden sich oder fehlen im restic-Repository.

## Aufräumen:
fusermount -u /tmp/restic-check


Methode 2: Integritätstest der Repository-Struktur
--------------------------------------------------
## Bevor du die rsnapshot-Daten löschst, solltest du sicherstellen, dass restic/rustic die Daten nicht nur empfangen hat, sondern diese auch lesbar und konsistent sind.

## Prüft, ob alle Hashes im Repo korrekt sind und keine Datenpakete fehlen
rustic -r "/pfad/zu/restic-repo" check


Methode 3: Stichprobenartige Kontrolle (ls)
-------------------------------------------
## Falls du nur schnell prüfen willst, ob die Pfade durch --as-path korrekt "umgebogen" wurden, kannst du die Dateiliste des neuesten Snapshots ausgeben:
rustic -r "/pfad/zu/restic-repo" ls latest

## Hier solltest du sehen, dass die Dateien direkt unter / (oder deinem gewählten TARGET_PATH) liegen und nicht mehr tief verschachtelt im rsnapshot-Pfad.

EOF
