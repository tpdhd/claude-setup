# Cursor Windows Explorer Integration - Automatisches Setup
# Version: 1.0
# Datum: 2026-01-08

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cursor Windows Explorer Integration" -ForegroundColor Cyan
Write-Host "Automatisches Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Finde Cursor Installation
$cursorPath = "$env:LOCALAPPDATA\Programs\cursor\resources\app\bin"

Write-Host "[1/7] Prüfe Cursor Installation..." -ForegroundColor Yellow
if (-not (Test-Path $cursorPath)) {
    Write-Host "❌ FEHLER: Cursor nicht gefunden in $cursorPath" -ForegroundColor Red
    Write-Host "Bitte installiere Cursor zuerst!" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Cursor gefunden: $cursorPath" -ForegroundColor Green
Write-Host ""

# Backup erstellen
Write-Host "[2/7] Erstelle Backup..." -ForegroundColor Yellow
$backupPath = "$env:USERPROFILE\cursor-setup-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

if (Test-Path "$cursorPath\cursor.cmd") {
    Copy-Item "$cursorPath\cursor.cmd" "$backupPath\cursor.cmd" -Force
    Write-Host "✓ Backup erstellt: $backupPath" -ForegroundColor Green
} else {
    Write-Host "⚠ cursor.cmd nicht gefunden - kein Backup nötig" -ForegroundColor Yellow
}
Write-Host ""

# Benenne cursor zu cursor.sh
Write-Host "[3/7] Benenne Linux-Script um..." -ForegroundColor Yellow
if (Test-Path "$cursorPath\cursor") {
    Move-Item "$cursorPath\cursor" "$cursorPath\cursor.sh" -Force
    Write-Host "✓ cursor → cursor.sh" -ForegroundColor Green
} else {
    Write-Host "⚠ cursor (ohne Endung) nicht gefunden - überspringe" -ForegroundColor Yellow
}
Write-Host ""

# Benenne cursor.cmd zu cursor-actual.cmd
Write-Host "[4/7] Benenne cursor.cmd um..." -ForegroundColor Yellow
if (Test-Path "$cursorPath\cursor.cmd") {
    Move-Item "$cursorPath\cursor.cmd" "$cursorPath\cursor-actual.cmd" -Force
    Write-Host "✓ cursor.cmd → cursor-actual.cmd" -ForegroundColor Green
} else {
    Write-Host "⚠ cursor.cmd nicht gefunden" -ForegroundColor Yellow
}
Write-Host ""

# Erstelle cursor-actual.cmd mit neuer Logik
Write-Host "[5/7] Erstelle cursor-actual.cmd..." -ForegroundColor Yellow
$cursorActualContent = @'
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
'@
Set-Content -Path "$cursorPath\cursor-actual.cmd" -Value $cursorActualContent -Force
Write-Host "✓ cursor-actual.cmd erstellt" -ForegroundColor Green
Write-Host ""

# Erstelle cursor.vbs
Write-Host "[6/7] Erstelle cursor.vbs..." -ForegroundColor Yellow
$cursorVbsContent = @'
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
'@
Set-Content -Path "$cursorPath\cursor.vbs" -Value $cursorVbsContent -Force
Write-Host "✓ cursor.vbs erstellt" -ForegroundColor Green
Write-Host ""

# Erstelle cursor.bat
Write-Host "[7/7] Erstelle cursor.bat..." -ForegroundColor Yellow
$cursorBatContent = @'
@echo off
wscript.exe "%~dp0cursor.vbs" %*
'@
Set-Content -Path "$cursorPath\cursor.bat" -Value $cursorBatContent -Force
Write-Host "✓ cursor.bat erstellt" -ForegroundColor Green
Write-Host ""

# Verifiziere Installation
Write-Host "Verifiziere Installation..." -ForegroundColor Yellow
Write-Host ""

$files = @("cursor.sh", "cursor-actual.cmd", "cursor.vbs", "cursor.bat")
$allFound = $true
foreach ($file in $files) {
    if (Test-Path "$cursorPath\$file") {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file fehlt!" -ForegroundColor Red
        $allFound = $false
    }
}
Write-Host ""

# Prüfe welchen Befehl Windows findet
Write-Host "Prüfe Windows PATH Priorität..." -ForegroundColor Yellow
$cursorCommand = Get-Command cursor -ErrorAction SilentlyContinue
if ($cursorCommand) {
    Write-Host "  ✓ Windows findet: $($cursorCommand.Name)" -ForegroundColor Green
    Write-Host "  ✓ Pfad: $($cursorCommand.Source)" -ForegroundColor Green

    if ($cursorCommand.Name -eq "cursor.bat") {
        Write-Host "  ✓ Korrekt! cursor.bat hat Priorität" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ WARNUNG: $($cursorCommand.Name) hat Priorität, nicht cursor.bat" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ 'cursor' Befehl nicht gefunden in PATH!" -ForegroundColor Red
    $allFound = $false
}
Write-Host ""

# Starte Explorer neu
Write-Host "Möchtest du Windows Explorer neu starten? (Empfohlen)" -ForegroundColor Yellow
Write-Host "Dies ist nötig, damit die Änderungen wirksam werden." -ForegroundColor Yellow
$restart = Read-Host "Explorer neu starten? (J/N)"

if ($restart -eq "J" -or $restart -eq "j" -or $restart -eq "Y" -or $restart -eq "y") {
    Write-Host ""
    Write-Host "Starte Windows Explorer neu..." -ForegroundColor Yellow
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer
    Write-Host "✓ Explorer neugestartet" -ForegroundColor Green
}

# Zusammenfassung
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation abgeschlossen!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allFound) {
    Write-Host "✅ Alle Dateien erfolgreich erstellt!" -ForegroundColor Green
    Write-Host ""
    Write-Host "So verwendest du es:" -ForegroundColor Yellow
    Write-Host "  1. Öffne einen Ordner im Windows Explorer" -ForegroundColor White
    Write-Host "  2. Klicke in die Adresszeile (oder drücke Alt+D)" -ForegroundColor White
    Write-Host "  3. Tippe: cursor" -ForegroundColor White
    Write-Host "  4. Drücke Enter" -ForegroundColor White
    Write-Host ""
    Write-Host "Cursor öffnet sich im aktuellen Ordner - ohne CMD-Fenster!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Backup gespeichert in: $backupPath" -ForegroundColor Cyan
} else {
    Write-Host "⚠ Es gab Probleme bei der Installation!" -ForegroundColor Yellow
    Write-Host "Bitte prüfe die Fehlermeldungen oben." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Backup gespeichert in: $backupPath" -ForegroundColor Cyan
    Write-Host "Bei Problemen kannst du die Backup-Dateien zurückkopieren." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Drücke eine Taste zum Beenden..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
