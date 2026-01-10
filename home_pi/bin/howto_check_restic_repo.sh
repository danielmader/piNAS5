#!/bin/bash

cat << EOF

>> https://gemini.google.com/share/f358f66c74c3 <<

Methode 1: Der "Trockenlauf" mit rsync (Empfohlen)
--------------------------------------------------
## Snapshot einhängen:
## Erstelle einen Mount-Punkt und mounte das Repository:

  export SRC="/mnt/esata/rsnapshots" \\
  export REPO="/mnt/esata/restic-repo" \\
  && export PASSFILE="/mnt/data/.restic_secret" \\
  && sudo mkdir -p /tmp/restic \\
  && sudo restic -r \${REPO} -p \$PASSFILE mount /tmp/restic --allow-other &

## Vergleich ausführen:
## Wir vergleichen nun den rsnapshot-Ordner mit dem Pfad im Mount-Verzeichnis per rsync im Dry-Run Modus (-n):

  sudo rsync -nav --delete "/mnt/esata/rsnapshots/manual.23/homes/" "/tmp/restic/snapshots/latest/mnt/data/homes/"

## Ergebnis interpretieren:
## Wenn die Liste leer ist (bis auf Header/Footer): Die Daten sind identisch.
## Werden Dateien aufgelistet: Diese Dateien unterscheiden sich oder fehlen im restic-Repository.

## Aufräumen:

  sudo umount /tmp/restic
  fusermount -u /tmp/restic


Methode 2: Integritätstest der Repository-Struktur
--------------------------------------------------
## Bevor du die rsnapshot-Daten löschst, solltest du sicherstellen, dass restic/rustic die Daten nicht nur empfangen hat, sondern diese auch lesbar und konsistent sind.

## Prüft, ob alle Hashes im Repo korrekt sind und keine Datenpakete fehlen

  export REPO="/mnt/esata/restic-repo" \\
  && export PASSFILE="/mnt/data/.restic_secret" \\
  && sudo rustic -r \${REPO} -p \$PASSFILE check


Methode 3: Stichprobenartige Kontrolle (ls)
-------------------------------------------
## Falls du nur schnell prüfen willst, ob die Pfade durch --as-path korrekt "umgebogen" wurden, kannst du die Dateiliste des neuesten Snapshots ausgeben:

  export REPO="/mnt/esata/restic-repo" \\
  && export PASSFILE="/mnt/data/.restic_secret" \\
  && sudo rustic -r \${REPO} -p \$PASSFILE ls latest

## Hier solltest du sehen, dass die Dateien direkt unter / (oder deinem gewählten TARGET_PATH) liegen und nicht mehr tief verschachtelt im rsnapshot-Pfad.

EOF
