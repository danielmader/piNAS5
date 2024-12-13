#!/bin/bash

if [ ! $# -eq 3 ]
then
  echo -e "\n>>>> Berechtigungen für Verzeichnisse und Dateien separat und rekursiv anpassen."
  echo "  Aufruf:"
  echo "> $(basename "$0")  VERZEICHNISRECHTE  DATEIRECHTE  BASISVERZEICHNIS"
  
  ## https://stackoverflow.com/a/2500451
  BASEDIR='$BASEDIR'
  cat <<- EOF
	>>>> Ähnliche Befehle:
	>> OTHER alle Rechte entziehen:
	# chmod -R o-rwx "$BASEDIR"
		
	>> GROUP wx-Rechte für Dateien entziehen:
	# echo "Entziehe group wx-Rechte auf Dateien..."
	# find "$BASEDIR" -type f -exec chmod -R u+rw-x,g+r-wx "{}" \;
		
	>> Nur eine Verzeichnisebene anpassen:
	# echo "Entziehe group w-Rechte auf Ordner..."
	# chmod -R g-w "$BASEDIR"

	>> Nur eine Verzeichnisebene anpassen:
	# find -type d -maxdepth 1 -exec chmod 711 {} \;

	>> Rechte bestimmter Typen anpassen:
	# find "$BASEDIR" -name "*.sh" -exec chmod 740 "{}" \;
	# find "$BASEDIR" -name "*.jar" -exec chmod 740 "{}" \;
	
	EOF
  exit 1
fi

pDirs=$1
pFiles=$2
BASEDIR=$3

echo -e "\n>>>> Processing $BASEDIR ..."

echo ">> Changing directory permissions to $pDirs ..."
#find "$BASEDIR" -type d -exec chmod -R "$pDirs" {} \;
find "$BASEDIR" \! -perm "$pDirs" -type d -exec stat -c "%a %n" {} \; #-exec echo '...' \;
find "$BASEDIR" \! -perm "$pDirs" -type d -exec chmod "$pDirs" {} \;

echo ">> Changing file permissions to $pFiles ..."
#find "$BASEDIR" -type f -exec chmod -R "$pFiles" {} \;
find "$BASEDIR" \! -perm "$pFiles" -type f -exec stat -c "%a %n" {} \; #-exec echo '...' \;
find "$BASEDIR" \! -perm "$pFiles" -type f -exec chmod "$pFiles" {} \;

echo "<<<< Done!"
