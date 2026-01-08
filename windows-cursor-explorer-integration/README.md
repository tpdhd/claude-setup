# Cursor Windows Explorer Integration

Öffne Cursor IDE direkt aus der Windows Explorer Adresszeile - ohne CMD-Fenster, ohne zusätzliche Argumente!

## Quick Start

### Automatische Installation (Empfohlen)

1. **Download dieses Repository**
2. **Rechtsklick** auf `setup-cursor-explorer.ps1`
3. **"Mit PowerShell ausführen"**
4. Fertig! 🎉

### Nach Installation

1. Öffne einen Ordner im Windows Explorer
2. Klicke in die Adresszeile (oder `Alt + D`)
3. Tippe: `cursor`
4. Enter drücken

Cursor öffnet sich im aktuellen Ordner!

## Was macht dieses Setup?

✅ **Kein CMD-Fenster** - Verwendet VBScript um CMD zu verstecken
✅ **Kein Punkt nötig** - Automatisch aktueller Ordner wird geöffnet
✅ **Keine Konflikte** - Behebt Datei-Prioritätsprobleme
✅ **Standard-kompatibel** - Alle normalen Argumente funktionieren weiter

## Dateien in diesem Ordner

| Datei | Beschreibung |
|-------|--------------|
| `CURSOR-WINDOWS-EXPLORER-SETUP.md` | **Vollständige Dokumentation** mit technischen Details |
| `setup-cursor-explorer.ps1` | **Automatisches Setup-Script** (empfohlen) |
| `uninstall-cursor-explorer.ps1` | Deinstallations-Script |
| `templates/` | Template-Dateien für manuelle Installation |

## Dokumentation

📖 **Siehe:** [CURSOR-WINDOWS-EXPLORER-SETUP.md](./CURSOR-WINDOWS-EXPLORER-SETUP.md)

Die vollständige Dokumentation enthält:
- Problemerklärung (Standard vs. unsere Lösung)
- Manuelle Installation (Schritt-für-Schritt)
- Technische Details (für KI-Assistenten)
- Fehlersuche
- Vergleich mit Community-Lösungen

## Voraussetzungen

- Windows 10/11
- Cursor IDE installiert
- Cursor Shell Command bereits in PATH

## Vergleich: Standard vs. Unsere Lösung

### Standard (Offizielle Methode)

```
❌ Eingabe: cursor .        (Punkt erforderlich)
❌ CMD-Fenster blinkt auf
```

### Unsere Lösung

```
✅ Eingabe: cursor          (kein Punkt nötig)
✅ Kein CMD-Fenster
✅ Gleiche Funktionalität
```

## Deinstallation

Führe aus: `uninstall-cursor-explorer.ps1`

Oder manuell:
```powershell
cd $env:LOCALAPPDATA\Programs\cursor\resources\app\bin
Remove-Item cursor.bat, cursor.vbs
Rename-Item cursor-actual.cmd cursor.cmd
Rename-Item cursor.sh cursor
```

## Support & Quellen

- [Cursor Forum - Terminal Integration](https://forum.cursor.com/t/how-to-open-cursor-from-terminal/3757)
- [VS Code GitHub Issue](https://github.com/microsoft/vscode/issues/43237)

## Version

**Version:** 1.0
**Datum:** 2026-01-08
**Kompatibel:** Windows 10/11, Cursor IDE
**Auch anwendbar für:** VS Code (gleiche Methode)
