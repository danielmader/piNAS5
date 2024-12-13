# Erklärung: Parsen der Optionen im Bash-Skript

Das Parsen der Optionen in der `while`-Schleife erfolgt wie folgt:

## Struktur
Die Schleife verarbeitet nacheinander alle Argumente, die beim Aufruf des Skripts übergeben wurden. Das erfolgt, solange noch Argumente (`"$#"` gibt die Anzahl der verbleibenden Argumente an) vorhanden sind.

```bash
while [[ "$#" -gt 0 ]]; do
    case "$1" in
```

- `"$1"` ist das erste (aktuelle) Argument in der Liste.
- Die Schleife arbeitet das erste Argument ab und verschiebt sich danach zum nächsten.

## `case`-Statement
Das `case`-Statement überprüft, welches Argument vorliegt, und führt den entsprechenden Codeblock aus.

### Optionen wie `-s` oder `--snapshot-dir`
```bash
    -s|--snapshot-dir)
        SNAPSHOT_DIR="$2"
        shift 2
        ;;
```
- Hier wird geprüft, ob das aktuelle Argument (`"$1"`) entweder `-s` oder `--snapshot-dir` ist.
- Wenn ja:
  - Der nächste Wert (`"$2"`) wird in die Variable `SNAPSHOT_DIR` geschrieben. Dies ist der Wert, der nach `-s` erwartet wird.
  - Mit `shift 2` werden die beiden verarbeiteten Argumente entfernt (z. B. `-s` und der Pfad).

### Option `--debug`
```bash
    --debug)
        DEBUG=true
        shift
        ;;
```
- Wenn das aktuelle Argument `--debug` ist, wird die Variable `DEBUG` auf `true` gesetzt.
- Es gibt keinen weiteren Wert, daher wird nur das aktuelle Argument mit `shift` entfernt.

### Hilfeaufruf `-h` oder `--help`
```bash
    -h|--help)
        usage
        ;;
```
- Wenn `-h` oder `--help` eingegeben wird, wird die Funktion `usage` aufgerufen, die die Hilfeinformationen anzeigt.

### Verarbeitung des `TARGET_DIR`
```bash
    *)
        if [[ -z "$TARGET_DIR" ]]; then
            TARGET_DIR="$1"
            shift
        else
            echo "Unbekannte Option oder mehrfaches Zielverzeichnis: $1"
            usage
        fi
        ;;
```
- Das `*`-Pattern fängt alle Argumente ab, die nicht explizit oben definiert sind.
- In diesem Fall:
  - Wenn die Variable `TARGET_DIR` noch leer ist (überprüft mit `[[ -z "$TARGET_DIR" ]]`), wird das aktuelle Argument als `TARGET_DIR` gespeichert.
  - Danach wird mit `shift` zum nächsten Argument gewechselt.
  - Wenn `TARGET_DIR` jedoch schon belegt ist, handelt es sich um einen Fehler, weil ein mehrfaches Zielverzeichnis oder eine unbekannte Option angegeben wurde. Es wird eine Fehlermeldung angezeigt, und die Hilfe wird aufgerufen.

## Abschlussprüfung
Nach der Schleife werden zwei wichtige Überprüfungen durchgeführt:

### Zielverzeichnis prüfen
```bash
if [[ -z "$TARGET_DIR" ]]; then
    echo "Fehler: Zielverzeichnis muss angegeben werden."
    usage
fi
```
- Wenn kein Zielverzeichnis angegeben wurde (Variable `TARGET_DIR` ist leer), wird ein Fehler ausgegeben, und die Hilfe wird angezeigt.

### Existenz des Snapshot-Verzeichnisses prüfen
```bash
if [[ ! -d "$SNAPSHOT_DIR" ]]; then
    echo "Fehler: Snapshot-Verzeichnis $SNAPSHOT_DIR existiert nicht."
    exit 1
fi
```
- Wenn das angegebene oder Standard-Snapshot-Verzeichnis nicht existiert, wird ein Fehler gemeldet, und das Skript bricht ab.

## Zusammenfassung
Die Schleife dient dazu:
1. Optionen wie `-s` und `--debug` zu erkennen und zu verarbeiten.
2. Das Zielverzeichnis (`TARGET_DIR`) als obligatorisches erstes Argument zuzuweisen.
3. Fehlende oder unzulässige Optionen zu behandeln.

Durch das `case`-Statement bleibt der Code klar strukturiert und gut erweiterbar.

