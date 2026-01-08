# Cursor Windows Explorer Integration - Deinstallation
# Version: 1.0
# Datum: 2026-01-08

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Cursor Windows Explorer Integration" -ForegroundColor Cyan
Write-Host "Deinstallation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$cursorPath = "$env:LOCALAPPDATA\Programs\cursor\resources\app\bin"

Write-Host "Dieser Script stellt das Standard-Setup von Cursor wieder her." -ForegroundColor Yellow
Write-Host ""
Write-Host "Was wird gemacht:" -ForegroundColor Yellow
Write-Host "  - cursor.bat wird gelöscht" -ForegroundColor White
Write-Host "  - cursor.vbs wird gelöscht" -ForegroundColor White
Write-Host "  - cursor-actual.cmd → cursor.cmd" -ForegroundColor White
Write-Host "  - cursor.sh → cursor" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Möchtest du fortfahren? (J/N)"
if ($confirm -ne "J" -and $confirm -ne "j" -and $confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Abgebrochen." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "[1/5] Prüfe Cursor Installation..." -ForegroundColor Yellow
if (-not (Test-Path $cursorPath)) {
    Write-Host "❌ FEHLER: Cursor nicht gefunden in $cursorPath" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Cursor gefunden: $cursorPath" -ForegroundColor Green
Write-Host ""

# Lösche cursor.bat
Write-Host "[2/5] Lösche cursor.bat..." -ForegroundColor Yellow
if (Test-Path "$cursorPath\cursor.bat") {
    Remove-Item "$cursorPath\cursor.bat" -Force
    Write-Host "✓ cursor.bat gelöscht" -ForegroundColor Green
} else {
    Write-Host "⚠ cursor.bat nicht gefunden" -ForegroundColor Yellow
}
Write-Host ""

# Lösche cursor.vbs
Write-Host "[3/5] Lösche cursor.vbs..." -ForegroundColor Yellow
if (Test-Path "$cursorPath\cursor.vbs") {
    Remove-Item "$cursorPath\cursor.vbs" -Force
    Write-Host "✓ cursor.vbs gelöscht" -ForegroundColor Green
} else {
    Write-Host "⚠ cursor.vbs nicht gefunden" -ForegroundColor Yellow
}
Write-Host ""

# Benenne cursor-actual.cmd zurück
Write-Host "[4/5] Stelle cursor.cmd wieder her..." -ForegroundColor Yellow
if (Test-Path "$cursorPath\cursor-actual.cmd") {
    if (Test-Path "$cursorPath\cursor.cmd") {
        Write-Host "⚠ cursor.cmd existiert bereits - überspringe" -ForegroundColor Yellow
    } else {
        Move-Item "$cursorPath\cursor-actual.cmd" "$cursorPath\cursor.cmd" -Force
        Write-Host "✓ cursor-actual.cmd → cursor.cmd" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ cursor-actual.cmd nicht gefunden" -ForegroundColor Yellow
}
Write-Host ""

# Benenne cursor.sh zurück (optional)
Write-Host "[5/5] Stelle cursor (Linux-Script) wieder her..." -ForegroundColor Yellow
if (Test-Path "$cursorPath\cursor.sh") {
    if (Test-Path "$cursorPath\cursor") {
        Write-Host "⚠ cursor (ohne Endung) existiert bereits - überspringe" -ForegroundColor Yellow
    } else {
        Move-Item "$cursorPath\cursor.sh" "$cursorPath\cursor" -Force
        Write-Host "✓ cursor.sh → cursor" -ForegroundColor Green
    }
} else {
    Write-Host "⚠ cursor.sh nicht gefunden" -ForegroundColor Yellow
}
Write-Host ""

# Verifiziere
Write-Host "Verifiziere Deinstallation..." -ForegroundColor Yellow
Write-Host ""

$shouldNotExist = @("cursor.bat", "cursor.vbs", "cursor-actual.cmd", "cursor.sh")
$shouldExist = @("cursor.cmd")

foreach ($file in $shouldNotExist) {
    if (Test-Path "$cursorPath\$file") {
        Write-Host "  ⚠ $file existiert noch" -ForegroundColor Yellow
    } else {
        Write-Host "  ✓ $file entfernt" -ForegroundColor Green
    }
}

foreach ($file in $shouldExist) {
    if (Test-Path "$cursorPath\$file") {
        Write-Host "  ✓ $file wiederhergestellt" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file fehlt!" -ForegroundColor Red
    }
}
Write-Host ""

# Explorer neu starten
Write-Host "Möchtest du Windows Explorer neu starten?" -ForegroundColor Yellow
$restart = Read-Host "Explorer neu starten? (J/N)"

if ($restart -eq "J" -or $restart -eq "j" -or $restart -eq "Y" -or $restart -eq "y") {
    Write-Host ""
    Write-Host "Starte Windows Explorer neu..." -ForegroundColor Yellow
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Start-Process explorer
    Write-Host "✓ Explorer neugestartet" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Deinstallation abgeschlossen!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Cursor ist jetzt wieder im Standard-Setup:" -ForegroundColor Green
Write-Host "  - Verwende: cursor ." -ForegroundColor White
Write-Host "  - CMD-Fenster wird kurz erscheinen" -ForegroundColor White
Write-Host ""
Write-Host "Drücke eine Taste zum Beenden..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
