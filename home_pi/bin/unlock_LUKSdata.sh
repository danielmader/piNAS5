#!/bin/bash

## Konfiguration
SECRET1="/home/pi/.secret1"
SECRET_USB="/home/pi/.secretUSB"
SECRET2_USB="/mnt/usb/cryptkey_rsa#2"
SECRET2_EXT=1HPepbUIkCD6b3kPvYDQSJT74ED2ZEPec

## Status-Variable, um zu prüfen, ob der Key gefunden wurde
KEY_FOUND=false
SECRET2=""

echo ">>>> Starte Entschlüsselungsprozess..."

## 1) Versuch: 2. Schlüsselfragment vom USB-Stick holen ========================

## Versuche sdc1 oder sdd1 zu öffnen
DEVICE_PATH=""
if cryptsetup open --type luks /dev/sdc1 usb --key-file="$SECRET_USB" 2>/dev/null; then
    echo "Erfolgreich an /dev/sdc1 geöffnet."
    DEVICE_PATH="/dev/sdc1"
elif cryptsetup open --type luks /dev/sdd1 usb --key-file="$SECRET_USB" 2>/dev/null; then
    echo "Erfolgreich an /dev/sdd1 geöffnet."
    DEVICE_PATH="/dev/sdd1"
else
    echo "Warnung: USB-Gerät konnte weder auf /dev/sdc1 noch auf /dev/sdd1 entschlüsselt werden."
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
                echo "Schlüssel erfolgreich vom USB-Stick gelesen."
                KEY_FOUND=true
            else
                echo "Fehler: Schlüsseldatei auf USB-Stick ist leer."
            fi
        else
            echo "Fehler: Schlüsseldatei nicht auf dem USB-Stick gefunden."
        fi

        ## Aufräumen: USB-Stick sofort wieder unmounten und schließen (Sicherheit)
        umount /mnt/usb
        cryptsetup close usb
        echo "USB-Stick wieder ausgehängt und geschlossen."
    else
        echo "Fehler: Gerät konnte nicht gemountet werden."
        ## Falls mount fehlschlägt, mapper trotzdem schließen
        cryptsetup close usb
    fi
fi

## 2) Versuch: 2. Schlüsselfragment von Google Drive holen (Fallback) ==========
## https://drive.google.com/file/d/<SECRET2_EXT>/view?usp=sharing
## https://drive.google.com/uc?id=<SECRET2_EXT>&export=download

if [ "$KEY_FOUND" = false ]; then
    echo -e "\n>>>> USB-Lesen fehlgeschlagen. Versuche Download von Google Drive..."

    ## -q für "quiet" (weniger Output), -O- für Ausgabe auf Stdout
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
    echo -n "$SECRET12" | /usr/sbin/cryptsetup open --type luks /dev/sda data1 --key-file=-
    RESULT1=$?

    echo -n "$SECRET12" | /usr/sbin/cryptsetup open --type luks /dev/sdb data2 --key-file=-
    RESULT2=$?

    ## Variable SECRET12 sofort aus dem Speicher löschen
    unset SECRET12
    unset SECRET2

    if [ $RESULT1 -eq 0 ] && [ $RESULT2 -eq 0 ]; then
        echo "Laufwerke erfolgreich entschlüsselt."

        ## Mount RAID
        echo "Mounte RAID..."
        /usr/bin/mount /srv/dev-disk-by-uuid-db25f167-dffc-47de-98ff-cab6a0e272c8
    else
        echo "Fehler beim Entschlüsseln der Laufwerke."
        exit 1
    fi
else
    echo "Abbruch: Kein Schlüssel vorhanden."
    exit 1
fi
