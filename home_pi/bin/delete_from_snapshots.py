"""
https://chatgpt.com/share/6741a1d7-437c-8005-9f56-16edf8cbd6c4
"""

import os
import sys
import shutil
import argparse


##==============================================================================
def delete_target_dir(snapshot_base, target_dir, debug=False):
    """Löscht ein Zielverzeichnis rekursiv aus allen Snapshots oder zeigt nur Debug-Informationen."""
    if not os.path.exists(snapshot_base):
        print(f"Snapshot-Basisverzeichnis '{snapshot_base}' existiert nicht.")
        return

    for root, dirs, _ in os.walk(snapshot_base):
        if target_dir in dirs:
            full_path = os.path.join(root, target_dir)
            if debug:
                print(f"[DEBUG] Lösche Verzeichnis: {full_path}")
            else:
                print(f"Lösche Verzeichnis: {full_path}")
                shutil.rmtree(full_path, ignore_errors=True)

    if debug:
        print("[DEBUG] Debug-Modus: Kein Verzeichnis wurde tatsächlich gelöscht.")
    else:
        print("Löschen abgeschlossen.")


##******************************************************************************
##******************************************************************************
if __name__ == "__main__":
    snapshot_dir_default = "/pfad/zu/rsnapshot-backups/"
    snapshot_dir_default = "/mnt/esata/rsnapshots/"
    snapshot_dir_default = "/srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8/esata/rsnapshots/"

    ## Argumentparser erstellen
    parser = argparse.ArgumentParser(description="Rekursives Löschen von Verzeichnissen aus rsnapshot-Backups.")
    parser.add_argument(
        "target_dir",
        type=str,
        help="Das relative Zielverzeichnis, das aus den Snapshots gelöscht werden soll.")
    parser.add_argument(
        "-s", "--snapshot-dir",
        default=snapshot_dir_default,
        help=f"Das Basisverzeichnis der rsnapshot-Snapshots (Standard: {snapshot_dir_default}).")
    parser.add_argument(
        "-d", "--debug",
        action="store_true",
        help="Debug-Modus: Nur anzeigen, was gelöscht würde.")
    args = parser.parse_args()

    ## Argumente parsen
    args = parser.parse_args()

    ## Debug-Modus-Anzeige
    if args.debug:
        print(f"[DEBUG] Snapshot-Verzeichnis: {args.snapshot_dir}")
        print(f"[DEBUG] Zielverzeichnis: {args.target_dir}")

    ## Funktion aufrufen
    try:
        delete_target_dir(args.snapshot_dir, args.target_dir, args.debug)
    except KeyboardInterrupt:
        sys.exit()
