# Windows Cursor Explorer Integration

## Problem

Cursor IDE soll aus der Windows Explorer Adresszeile gestartet werden können, aber die Standard-Methode hat Probleme:

**Standard-Methode:**
1. Cursor: `Ctrl+Shift+P` → "Shell Command: Install 'cursor' command in PATH"
2. Windows fügt `C:\Users\USERNAME\AppData\Local\Programs\cursor\resources\app\bin` zu PATH
3. User muss eingeben: `cursor .` (mit Punkt!)

**Probleme Standard-Methode:**
- ❌ CMD-Fenster blinkt auf und muss geschlossen werden
- ❌ Punkt (`.`) muss eingegeben werden für aktuellen Ordner
- ❌ Datei-Konflikt: `cursor` (Linux-Script) vs `cursor.cmd` (Windows) → Windows weiß nicht welche Datei

**Bekannte Issues:**
- [VS Code GitHub #43237](https://github.com/microsoft/vscode/issues/43237) - "Enable 'code .' in Windows Explorer"
- [VS Code GitHub #18230](https://github.com/Microsoft/vscode/issues/18230) - "code.cmd precedence problem"
- [Cursor Forum](https://forum.cursor.com/t/how-to-open-cursor-from-terminal/3757) - Community Diskussionen

---

## Lösung

**Verbesserte Methode:**
- ✅ Kein CMD-Fenster (VBScript versteckt es)
- ✅ Kein Punkt nötig (automatisch aktueller Ordner)
- ✅ Keine Konflikte (Datei-Prioritäten gelöst)

**Datei-Kette:**
```
User tippt "cursor" → cursor.bat → cursor.vbs → cursor-actual.cmd → Cursor.exe
                      (Einstieg)   (versteckt) (Logik+Punkt)      (öffnet)
```

**Warum diese Architektur:**
1. `cursor.bat` - Windows PATH-Priorität: `.BAT` > `.CMD` > `.VBS`
2. `cursor.vbs` - VBScript kann CMD-Fenster verstecken (WindowStyle=0)
3. `cursor-actual.cmd` - Prüft Argumente, fügt automatisch `.` hinzu wenn leer
4. `cursor.sh` - Umbenanntes Linux-Script (stört nicht mehr)

---

## Implementation für KI

### Schritt 1: Prüfe und finde Cursor

```bash
# Setze Cursor Path
cursor_bin="/mnt/c/Users/$USER/AppData/Local/Programs/cursor/resources/app/bin"

# Prüfe ob existiert
test -d "$cursor_bin" || { echo "ERROR: Cursor nicht gefunden"; exit 1; }
```

### Schritt 2: Benenne Linux-Script um

```bash
# cursor → cursor.sh (damit Windows es ignoriert)
test -f "$cursor_bin/cursor" && mv "$cursor_bin/cursor" "$cursor_bin/cursor.sh"
```

### Schritt 3: Benenne cursor.cmd um

```bash
# cursor.cmd → cursor-actual.cmd (wird Worker-Script)
test -f "$cursor_bin/cursor.cmd" && mv "$cursor_bin/cursor.cmd" "$cursor_bin/cursor-actual.cmd"
```

### Schritt 4: Erstelle cursor-actual.cmd mit Auto-Punkt-Logik

```bash
cat > "$cursor_bin/cursor-actual.cmd" << 'EOF'
@echo off
setlocal
set VSCODE_DEV=
set ELECTRON_RUN_AS_NODE=1
if "%*"=="" (
    "%~dp0..\..\..\Cursor.exe" "%~dp0..\out\cli.js" .
) else (
    "%~dp0..\..\..\Cursor.exe" "%~dp0..\out\cli.js" %*
)
IF %ERRORLEVEL% NEQ 0 EXIT /b %ERRORLEVEL%
endlocal
EOF
```

**Was macht dieser Code:**
- `if "%*"==""` → Prüft ob Argumente leer
- Wenn leer → Fügt `.` hinzu (= aktueller Ordner)
- Wenn nicht leer → Übergibt Argumente unverändert

### Schritt 5: Erstelle cursor.vbs (CMD-Fenster-Verstecker)

```bash
cat > "$cursor_bin/cursor.vbs" << 'EOF'
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strCmdPath = objFSO.BuildPath(strScriptPath, "cursor-actual.cmd")

' Get current working directory
strCurrentDir = objShell.CurrentDirectory

' Build command with arguments
strCommand = "cmd.exe /c ""cd /d """ & strCurrentDir & """ && """ & strCmdPath & """"

' Add any arguments passed to the script
If WScript.Arguments.Count > 0 Then
    For i = 0 To WScript.Arguments.Count - 1
        strCommand = strCommand & " """ & WScript.Arguments(i) & """"
    Next
End If

strCommand = strCommand & """"

' Run hidden (0 = hidden window, False = don't wait)
objShell.Run strCommand, 0, False

Set objShell = Nothing
Set objFSO = Nothing
EOF
```

**Was macht dieser Code:**
- Liest aktuelles Verzeichnis (`CurrentDirectory`)
- Ruft `cursor-actual.cmd` auf
- Parameter `0` = Verstecktes Fenster (kein CMD sichtbar)
- Parameter `False` = Asynchron (nicht warten)

### Schritt 6: Erstelle cursor.bat (Einstiegspunkt)

```bash
cat > "$cursor_bin/cursor.bat" << 'EOF'
@echo off
wscript.exe "%~dp0cursor.vbs" %*
EOF
```

**Was macht dieser Code:**
- Ruft VBScript auf
- `%~dp0` = Pfad zum Script-Verzeichnis
- `%*` = Alle Argumente weitergeben

### Schritt 7: Starte Windows Explorer neu

```bash
powershell.exe -Command "Stop-Process -Name explorer -Force; Start-Sleep -Seconds 1; Start-Process explorer"
```

---

## Validierung

```bash
cursor_bin="/mnt/c/Users/$USER/AppData/Local/Programs/cursor/resources/app/bin"

# Prüfe alle Dateien
echo "=== Dateien Check ==="
test -f "$cursor_bin/cursor.sh" && echo "✓ cursor.sh" || echo "✗ cursor.sh"
test -f "$cursor_bin/cursor-actual.cmd" && echo "✓ cursor-actual.cmd" || echo "✗ cursor-actual.cmd"
test -f "$cursor_bin/cursor.vbs" && echo "✓ cursor.vbs" || echo "✗ cursor.vbs"
test -f "$cursor_bin/cursor.bat" && echo "✓ cursor.bat" || echo "✗ cursor.bat"

# Prüfe welche Datei Windows findet
echo ""
echo "=== Windows Priorität ==="
powershell.exe -Command "Get-Command cursor | Select-Object Name, Source"
# Erwartete Ausgabe: cursor.bat

# Funktionstest
echo ""
echo "=== Funktionstest ==="
cd /mnt/c/Users/$USER/Downloads
powershell.exe -Command "cursor ." &
echo "Cursor sollte sich jetzt öffnen..."
```

---

## Komplettes Setup-Script (Copy-Paste für KI)

```bash
#!/bin/bash
# Cursor Windows Explorer Integration - Automatisches Setup

echo "=== Cursor Windows Explorer Integration ==="

# 1. Setze Path
cursor_bin="/mnt/c/Users/$USER/AppData/Local/Programs/cursor/resources/app/bin"

# 2. Prüfe Cursor
if [ ! -d "$cursor_bin" ]; then
    echo "ERROR: Cursor nicht gefunden in $cursor_bin"
    exit 1
fi
echo "✓ Cursor gefunden"

# 3. Backup (optional)
backup_dir="/tmp/cursor-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
test -f "$cursor_bin/cursor.cmd" && cp "$cursor_bin/cursor.cmd" "$backup_dir/"
echo "✓ Backup: $backup_dir"

# 4. Benenne Dateien um
test -f "$cursor_bin/cursor" && mv "$cursor_bin/cursor" "$cursor_bin/cursor.sh"
test -f "$cursor_bin/cursor.cmd" && mv "$cursor_bin/cursor.cmd" "$cursor_bin/cursor-actual.cmd"
echo "✓ Dateien umbenannt"

# 5. Erstelle cursor-actual.cmd
cat > "$cursor_bin/cursor-actual.cmd" << 'EOF'
@echo off
setlocal
set VSCODE_DEV=
set ELECTRON_RUN_AS_NODE=1
if "%*"=="" (
    "%~dp0..\..\..\Cursor.exe" "%~dp0..\out\cli.js" .
) else (
    "%~dp0..\..\..\Cursor.exe" "%~dp0..\out\cli.js" %*
)
IF %ERRORLEVEL% NEQ 0 EXIT /b %ERRORLEVEL%
endlocal
EOF
echo "✓ cursor-actual.cmd erstellt"

# 6. Erstelle cursor.vbs
cat > "$cursor_bin/cursor.vbs" << 'EOF'
Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strCmdPath = objFSO.BuildPath(strScriptPath, "cursor-actual.cmd")

' Get current working directory
strCurrentDir = objShell.CurrentDirectory

' Build command with arguments
strCommand = "cmd.exe /c ""cd /d """ & strCurrentDir & """ && """ & strCmdPath & """"

' Add any arguments passed to the script
If WScript.Arguments.Count > 0 Then
    For i = 0 To WScript.Arguments.Count - 1
        strCommand = strCommand & " """ & WScript.Arguments(i) & """"
    Next
End If

strCommand = strCommand & """"

' Run hidden (0 = hidden window, False = don't wait)
objShell.Run strCommand, 0, False

Set objShell = Nothing
Set objFSO = Nothing
EOF
echo "✓ cursor.vbs erstellt"

# 7. Erstelle cursor.bat
cat > "$cursor_bin/cursor.bat" << 'EOF'
@echo off
wscript.exe "%~dp0cursor.vbs" %*
EOF
echo "✓ cursor.bat erstellt"

# 8. Explorer neu starten
echo "Starte Explorer neu..."
powershell.exe -Command "Stop-Process -Name explorer -Force; Start-Sleep -Seconds 1; Start-Process explorer"
echo "✓ Explorer neugestartet"

echo ""
echo "=== Installation abgeschlossen ==="
echo "Verwendung:"
echo "  1. Öffne Ordner im Windows Explorer"
echo "  2. Klicke in Adresszeile (Alt+D)"
echo "  3. Tippe: cursor"
echo "  4. Enter"
echo ""
echo "Backup gespeichert in: $backup_dir"
```

---

## Verwendung

**User-Workflow:**
1. Öffne beliebigen Ordner in Windows Explorer
2. Klicke in Adresszeile (oder `Alt+D`)
3. Tippe: `cursor` (ohne Punkt!)
4. Enter

**Mit Argumenten:**
- `cursor` → Öffnet aktuellen Ordner
- `cursor MeinProjekt` → Öffnet Unterordner "MeinProjekt"
- `cursor README.md` → Öffnet Datei
- `cursor -n` → Neues Fenster

---

## Troubleshooting

### Problem: "cursor: command not found"

**Ursache:** Cursor bin nicht in PATH

**Lösung:**
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Users\USERNAME\AppData\Local\Programs\cursor\resources\app\bin", "User")
```

### Problem: CMD-Fenster erscheint immer noch

**Ursache:** Windows findet falsche Datei

**Prüfen:**
```bash
powershell.exe -Command "Get-Command cursor"
# Sollte zeigen: cursor.bat
```

**Lösung:** Stelle sicher dass `cursor.cmd` zu `cursor-actual.cmd` umbenannt wurde

### Problem: Cursor öffnet ohne Ordner

**Ursache:** VBScript liest falsches Verzeichnis

**Workaround:** Verwende explizit `cursor .`

---

## Deinstallation

```bash
cursor_bin="/mnt/c/Users/$USER/AppData/Local/Programs/cursor/resources/app/bin"

# Lösche neue Dateien
rm -f "$cursor_bin/cursor.bat"
rm -f "$cursor_bin/cursor.vbs"

# Stelle Original wieder her
test -f "$cursor_bin/cursor-actual.cmd" && mv "$cursor_bin/cursor-actual.cmd" "$cursor_bin/cursor.cmd"
test -f "$cursor_bin/cursor.sh" && mv "$cursor_bin/cursor.sh" "$cursor_bin/cursor"

# Explorer neu starten
powershell.exe -Command "Stop-Process -Name explorer -Force; Start-Sleep -Seconds 1; Start-Process explorer"

echo "Zurück zur Standard-Konfiguration"
```

---

## Technische Details

### Windows PATH Priorität
Windows durchsucht PATH und führt Dateien in dieser Reihenfolge aus:
1. `.COM`
2. `.EXE`
3. `.BAT` ← Unsere `cursor.bat`
4. `.CMD`
5. `.VBS`
6. `.VBE`
7. weitere...

### VBScript WindowStyle
```vbscript
objShell.Run strCommand, 0, False
                          ↑   ↑
                          │   └─ Wait: False = asynchron
                          └───── WindowStyle: 0 = versteckt
```

**WindowStyle-Werte:**
- `0` = Versteckt
- `1` = Normal
- `2` = Minimiert
- `3` = Maximiert

### Batch Argument-Prüfung
```batch
if "%*"=="" (
    REM Keine Argumente → Punkt hinzufügen
) else (
    REM Argumente vorhanden → weitergeben
)
```

- `%*` = Alle Argumente als String
- `""` = Leer-Check

---

## Dateien Übersicht

| Datei | Funktion | Priorität |
|-------|----------|-----------|
| `cursor.bat` | Einstiegspunkt, ruft VBS | 1 (höchste) |
| `cursor.vbs` | Versteckt CMD, ruft CMD | 2 |
| `cursor-actual.cmd` | Haupt-Logik, Auto-Punkt | 3 |
| `cursor.sh` | Linux-Script (inaktiv) | - |

---

## Quellen

- [Cursor Docs - Shell Commands](https://cursor.com/docs/configuration/shell)
- [VS Code Docs - CLI](https://code.visualstudio.com/docs/configure/command-line)
- [VS Code Issue #43237](https://github.com/microsoft/vscode/issues/43237) - Enable "code ." in Explorer
- [VS Code Issue #18230](https://github.com/Microsoft/vscode/issues/18230) - code.cmd precedence
- [Cursor Forum - Terminal Integration](https://forum.cursor.com/t/how-to-open-cursor-from-terminal/3757)

---

**Version:** 1.0
**Datum:** 2026-01-08
**Getestet:** Windows 10/11, Cursor IDE
**Auch anwendbar:** VS Code (gleiche Methode)
