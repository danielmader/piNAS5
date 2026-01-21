#!/bin/bash

## Configuration
SECRET1="/home/pi/cryptkey_rsa#1"
KEYFILE_USB="/home/pi/cryptkey_USB"
SECRET2_USB="/mnt/usb/cryptkey_rsa#2"
SECRET2_EXT="/home/pi/cryptkey_rsa#2_GoogleID"

## UUIDs
# $ lsblk -o NAME,FSTYPE,LABEL,UUID,PARTUUID,MOUNTPOINT
# $ blkid
USB="7b4854df-4dd7-40fb-9028-9e7eff418da0"
DISK1="12280554-001a-43f9-aa5a-a0547201fce6"
DISK2="fbfd2f96-25d2-45ac-99c1-d6647be23b55"
RAID="db25f167-dffc-47de-98ff-cab6a0e272c8"  # /dev/mapper/data1

## Status variables
KEY_FOUND=false
SECRET2=""

## 1) Versuch: 2. Schlüsselfragment vom USB-Gerät holen ========================

echo -e "\n>>>> Lese Schlüssel vom USB-Gerät..."

# cryptsetup open --type luks "/dev/disk/by-uuid/$USB" usb --key-file="$KEYFILE_USB" 2>/dev/null
if cryptsetup open --type luks "/dev/disk/by-uuid/$USB" usb --key-file="$KEYFILE_USB"; then
    echo "USB-Gerät erfolgreich entschlüsselt."
else
    echo "USB-Gerät konnte nicht gefunden/entschlüsselt werden!"
fi

## Wenn ein Gerät geöffnet wurde, versuchen zu mounten und zu lesen
if [ -e "/dev/mapper/usb" ]; then
    ## Sicherstellen, dass der Mountpunkt existiert
    mkdir -p /mnt/usb

    if mount /dev/mapper/usb /mnt/usb; then
        echo "Erfolgreich an /mnt/usb gemountet."

        if [ -f "$SECRET2_USB" ]; then
            SECRET2=$(cat "$SECRET2_USB")
            if [ -n "$SECRET2" ]; then
                echo "Schlüssel erfolgreich vom USB-Gerät gelesen."
                KEY_FOUND=true
            else
                echo "Fehler: Schlüsseldatei auf USB-Gerät ist leer!"
            fi
        else
            echo "Fehler: Schlüsseldatei nicht auf dem USB-Gerät gefunden!"
        fi

        ## Aufräumen: USB-Gerät sofort wieder unmounten und schließen (Sicherheit)
        umount /mnt/usb
        cryptsetup close usb
        echo "USB-Gerät wieder ausgehängt und geschlossen."
    else
        echo "Fehler: USB-Gerät konnte nicht gemountet werden."
        ## Falls mount fehlschlägt, mapper trotzdem schließen
        cryptsetup close usb
    fi
fi

## 2) Versuch: 2. Schlüsselfragment von Google Drive holen (Fallback) ==========
## https://drive.google.com/file/d/<SECRET2_EXT>/view?usp=sharing
## https://drive.google.com/uc?id=<SECRET2_EXT>&export=download

if [ "$KEY_FOUND" = false ]; then
    echo -e "\n>>>> Versuche Schlüssel-Download von Google Drive..."

    ## -q für "quiet" (weniger Output), -O- für Ausgabe auf Stdout
    SECRET2_EXT=$(cat "$SECRET2_EXT")
    SECRET2=$(wget -q "https://drive.google.com/uc?id=$SECRET2_EXT&export=download" -O-)

    if [ -n "$SECRET2" ]; then
        echo "Schlüssel erfolgreich heruntergeladen."
        KEY_FOUND=true
    else
        echo "Kritischer Fehler: Schlüssel konnte auch nicht von Google Drive geladen werden."
        exit 1
    fi
fi

## 3) Zusammenbau und Entschlüsselung ==========================================

if [ "$KEY_FOUND" = true ]; then
    echo -e "\n>>>> Setze vollständigen Schlüssel zusammen..."

    ## Zusammenfügen von lokalem Teil (SECRET1) und Variable (SECRET2)
    ## Nutzung von Prozess-Substitution <(...) ist sauberer als Pipe
    SECRET12=$(cat "$SECRET1" <(echo -n "$SECRET2"))

    echo -e "\n>>>> Entschlüssele LUKS Container..."

    ## Entschlüsselung versuchen
    ## Wir nutzen echo -n, um keine unnötigen Newlines einzufügen, falls das Passwort empfindlich ist
    # echo -n "$SECRET12" | /usr/sbin/cryptsetup open --type luks "/dev/disk/by-uuid/$DISK1" data1 --key-file=-
    # echo -n "$SECRET12" | /usr/sbin/cryptsetup open --type luks "/dev/disk/by-uuid/$DISK2" data2 --key-file=-
    echo "$SECRET12" | /usr/sbin/cryptsetup open --type luks "/dev/disk/by-uuid/$DISK1" data1 --key-file=-
    RESULT1=$?
    echo "$SECRET12" | /usr/sbin/cryptsetup open --type luks "/dev/disk/by-uuid/$DISK2" data2 --key-file=-
    RESULT2=$?

    ## Variablen sofort aus dem Speicher löschen
    unset SECRET12
    unset SECRET1
    unset SECRET2

    if [ $RESULT1 -eq 0 ] && [ $RESULT2 -eq 0 ]; then
        echo "RAID-Laufwerke erfolgreich entschlüsselt."
    else
        echo "Fehler beim Entschlüsseln der Laufwerke."
    fi
else
    echo "Abbruch: Kein Schlüssel vorhanden."
    exit 1
fi

## 4) Dateisystem mounten ======================================================

echo -e "\n>>>> Mounte RAID..."
## /etc/fstab
# /usr/bin/mount /dev/disk/by-uuid/$RAID /srv/dev-disk-by-uuid-$RAID
## manuell
/usr/bin/mount -t btrfs -o defaults,nofail,noatime /dev/disk/by-uuid/$RAID /mnt/data

if mount | grep "/mnt/data" > /dev/null; then
    echo "RAID-Dateisystem erfolgreich eingebunden."
else
    echo "Fehler beim Einbinden des RAID-Dateisytems!"
    exit 1
fi
