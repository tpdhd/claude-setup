# Claude Code Sound Notifications - Setup Anleitung

## Was sind Sound Notifications?

Sound Notifications geben dir ein **akustisches Signal**, wenn Claude Code fertig ist und auf deine Eingabe wartet.

**Vorteile:**
- Du musst nicht ständig auf den Bildschirm schauen
- Du weißt sofort, wenn Claude fertig ist
- Sehr hilfreich bei langen Operationen

**WICHTIG:**
- ❌ Sound Notifications sind NICHT standardmäßig aktiv
- ✅ Du MUSST sie selbst einrichten (siehe unten)
- Funktioniert mit Claude Code Hooks

**NOTE:** Sound hook scripts are now organized in the `sound-hooks/` directory in this repository. You can copy them from there or create them following the instructions below.

---

# Installation für WSL2 (Windows Subsystem for Linux)

## ⚠️ KRITISCH: WSL braucht eine ANDERE Lösung!

WSL hat **keine native Audio-Unterstützung**. Die Linux-basierten Lösungen (sox, mpg123) funktionieren NICHT in WSL!

**Die Lösung:** Wir nutzen **PowerShell** um Sounds über Windows abzuspielen.

## Was funktioniert in WSL:

✅ **Windows System Sounds** via PowerShell
✅ **Custom WAV Dateien** via PowerShell
✅ **Stop Hook** in `~/.claude.json` oder `~/.claude/settings.json`

❌ **NICHT:** Linux Audio Tools (sox, mpg123, aplay)
❌ **NICHT:** Terminal Bell (`\x07`) - kein Sound in WSL

---

## Quick Setup für WSL (Funktioniert zu 100%)

### Schritt 1: Erstelle das Sound-Notification Script

```bash
cat > ~/.claude/notify-sound.js << 'EOF'
#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const { exec, execSync } = require('child_process');

// Load config to determine which sound to play
const configPath = path.join(process.env.HOME, '.claude.json');

let config = {};
let soundChoice = 'terminal-bell'; // Default fallback

try {
  const configContent = fs.readFileSync(configPath, 'utf8');
  config = JSON.parse(configContent);
  soundChoice = config.soundNotification || 'terminal-bell';
} catch (error) {
  // If config doesn't exist or can't be read, use default
  console.error('Could not read config, using terminal-bell as fallback');
}

// Check if sound is enabled
if (config.soundEnabled === false) {
  // Sound is disabled, exit silently
  process.exit(0);
}

// Detect if running in WSL
function isWSL() {
  if (process.platform !== 'linux') {
    return false;
  }

  try {
    // Check for WSL-specific indicators
    const procVersion = fs.readFileSync('/proc/version', 'utf8').toLowerCase();
    return procVersion.includes('microsoft') || procVersion.includes('wsl');
  } catch (error) {
    return false;
  }
}

const runningInWSL = isWSL();

// Sound file paths
const soundsDir = path.join(process.env.HOME, '.claude', 'sounds');
const soundFiles = {
  'custom-notification': path.join(soundsDir, 'custom-notification.wav'),
  'gentle-chime': path.join(soundsDir, 'gentle-chime.mp3'),
  'success-ping': path.join(soundsDir, 'success-ping.mp3'),
  'soft-marimba': path.join(soundsDir, 'soft-marimba.mp3'),
  'digital-blip': path.join(soundsDir, 'digital-blip.mp3'),
  'terminal-bell': 'beep'
};

// Map sound choices to Windows system sounds for WSL
const windowsSystemSounds = {
  'custom-notification': 'Asterisk',   // Fallback if WAV file missing
  'gentle-chime': 'Asterisk',          // Soft, pleasant sound
  'success-ping': 'Exclamation',       // Positive notification
  'soft-marimba': 'Asterisk',          // Similar to gentle chime
  'digital-blip': 'Hand',              // Short, crisp sound
  'terminal-bell': 'Beep'              // Default system beep
};

// Convert WSL path to Windows path
function convertToWindowsPath(wslPath) {
  try {
    // Use wslpath command to convert
    const windowsPath = execSync(`wslpath -w "${wslPath}"`, { encoding: 'utf8' }).trim();
    return windowsPath;
  } catch (error) {
    console.error('Error converting path:', error.message);
    return null;
  }
}

// Platform-specific audio players
function getAudioCommand(soundFile) {
  const platform = process.platform;

  if (runningInWSL) {
    // WSL - Use PowerShell to play sounds through Windows
    if (soundChoice === 'terminal-bell') {
      // Use Windows system beep
      return `powershell.exe -Command "[System.Media.SystemSounds]::Beep.Play()"`;
    } else if (fs.existsSync(soundFile)) {
      // Convert WSL path to Windows path
      const windowsPath = convertToWindowsPath(soundFile);
      if (windowsPath) {
        // For WAV files, use a simpler approach with proper escaping
        if (soundFile.endsWith('.wav')) {
          // Use PowerShell with proper quoting
          const escapedPath = windowsPath.replace(/\\/g, '\\\\').replace(/'/g, "''");
          return `powershell.exe -Command "& {(New-Object Media.SoundPlayer '${escapedPath}').PlaySync()}"`;
        } else {
          // For MP3 and other formats, try Windows Media Player
          const escapedPath = windowsPath.replace(/\\/g, '\\\\').replace(/'/g, "''");
          return `powershell.exe -Command "& {Add-Type -AssemblyName presentationCore; \\$player = New-Object System.Windows.Media.MediaPlayer; \\$player.Open('${escapedPath}'); \\$player.Play(); Start-Sleep -Seconds 2}"`;
        }
      }
    }

    // Fallback to Windows system sound
    const systemSound = windowsSystemSounds[soundChoice] || 'Beep';
    return `powershell.exe -Command "[System.Media.SystemSounds]::${systemSound}.Play()"`;

  } else if (platform === 'darwin') {
    // macOS
    return `afplay "${soundFile}"`;
  } else if (platform === 'linux') {
    // Native Linux - try multiple players
    return `(which mpg123 >/dev/null 2>&1 && mpg123 -q "${soundFile}") || (which play >/dev/null 2>&1 && play -q "${soundFile}") || (which ffplay >/dev/null 2>&1 && ffplay -nodisp -autoexit -hide_banner "${soundFile}" 2>/dev/null)`;
  } else if (platform === 'win32') {
    // Native Windows
    return `powershell.exe -Command "(New-Object Media.SoundPlayer '${soundFile}').PlaySync()"`;
  }

  // Unknown platform
  return null;
}

// Play the sound
function playSound() {
  const soundFile = soundFiles[soundChoice];

  if (!soundFile) {
    console.error(`Unknown sound choice: ${soundChoice}`);
    // Fallback to beep
    if (runningInWSL) {
      exec(`powershell.exe -Command "[System.Media.SystemSounds]::Beep.Play()"`, () => process.exit(0));
    } else {
      process.stdout.write('\x07');
      process.exit(0);
    }
    return;
  }

  // Get the audio command
  const command = getAudioCommand(soundFile);

  if (command) {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        // Fallback to beep
        console.error(`Error playing sound: ${error.message}`);
        console.error('Falling back to system beep');
        if (runningInWSL) {
          exec(`powershell.exe -Command "[System.Media.SystemSounds]::Beep.Play()"`, () => process.exit(0));
        } else {
          process.stdout.write('\x07');
          process.exit(0);
        }
      } else {
        process.exit(0);
      }
    });
  } else {
    // Unsupported platform, use beep
    console.error('Unsupported platform, using system beep');
    if (runningInWSL) {
      exec(`powershell.exe -Command "[System.Media.SystemSounds]::Beep.Play()"`, () => process.exit(0));
    } else {
      process.stdout.write('\x07');
      process.exit(0);
    }
  }
}

// Execute
playSound();
EOF

chmod +x ~/.claude/notify-sound.js
```

### Schritt 2: Erstelle das Sounds-Verzeichnis

```bash
mkdir -p ~/.claude/sounds
```

### Schritt 3: Füge eine Custom Sound Datei hinzu (Optional)

Wenn du einen eigenen Sound nutzen möchtest (z.B. eine WAV Datei):

```bash
# Kopiere deine WAV-Datei nach ~/.claude/sounds/custom-notification.wav
# Beispiel:
cp "/mnt/c/Users/DEINNAME/Downloads/notification.wav" ~/.claude/sounds/custom-notification.wav
```

**Unterstützte Formate:**
- ✅ WAV (am zuverlässigsten in WSL)
- ✅ MP3 (funktioniert, aber langsamer)

### Schritt 4: Konfiguriere den Hook

**WICHTIG:** Claude Code sucht an **zwei** Stellen nach Hooks:

1. `~/.claude.json` (User-Konfiguration)
2. `~/.claude/settings.json` (Neuere Versionen bevorzugen dies)

**Lösung:** Beide Dateien anlegen!

#### Option A: Bearbeite ~/.claude.json

```bash
# Öffne die Datei
nano ~/.claude.json
```

Füge diesen Block hinzu (achte auf korrekte JSON-Syntax!):

```json
{
  "soundNotification": "custom-notification",
  "soundEnabled": true,
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node /home/DEINUSERNAME/.claude/notify-sound.js"
          }
        ]
      }
    ]
  }
}
```

**WICHTIG:** Ersetze `DEINUSERNAME` mit deinem tatsächlichen Linux-Username!

```bash
# Finde deinen Username:
echo $HOME
# Ausgabe z.B.: /home/hanspeter
# Dann nutze: /home/hanspeter/.claude/notify-sound.js
```

#### Option B: Erstelle ~/.claude/settings.json

```bash
cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node ~/.claude/notify-sound.js"
          }
        ]
      }
    ]
  }
}
EOF
```

**Hinweis:** Die Tilde `~` funktioniert in settings.json, aber nicht immer in .claude.json!

### Schritt 5: Sound-Optionen

Wähle einen der folgenden Sounds in deiner `~/.claude.json`:

```json
"soundNotification": "custom-notification"    // Deine eigene WAV-Datei
"soundNotification": "gentle-chime"           // Windows Asterisk Sound
"soundNotification": "success-ping"           // Windows Exclamation Sound
"soundNotification": "digital-blip"           // Windows Hand Sound
"soundNotification": "terminal-bell"          // Windows Beep (Standard)
```

### Schritt 6: Teste die Installation

**Test 1: Script direkt ausführen**

```bash
node ~/.claude/notify-sound.js
```

**Erwartung:** Du solltest einen Sound hören!

**Test 2: Starte Claude Code neu**

```bash
# 1. Beende alle Claude Sessions
# 2. Starte neu:
claude
# 3. Stelle eine Frage: "What is 2+2?"
# 4. Wenn Claude fertig ist, sollte der Sound spielen!
```

---

## Troubleshooting WSL

### Problem: Kein Sound wird abgespielt

**Diagnose:**

```bash
# Test ob PowerShell funktioniert:
powershell.exe -Command "[System.Media.SystemSounds]::Asterisk.Play()"
```

**Wenn Sound spielt:** PowerShell funktioniert, Problem liegt am Hook
**Wenn kein Sound:** Windows Audio-Problem

### Problem: Hook wird nicht getriggert

**Debug-Lösung:** Erstelle ein Debug-Script:

```bash
cat > ~/.claude/debug-hook.sh << 'EOF'
#!/bin/bash
echo "Hook triggered at $(date)" >> /tmp/claude-hook-debug.log
echo "Command: $0 $@" >> /tmp/claude-hook-debug.log
echo "Working directory: $(pwd)" >> /tmp/claude-hook-debug.log
echo "---" >> /tmp/claude-hook-debug.log

# Actually play the sound
node ~/.claude/notify-sound.js >> /tmp/claude-hook-debug.log 2>&1
EOF
chmod +x ~/.claude/debug-hook.sh
```

**Ändere deinen Hook zu:**

```json
"command": "/home/DEINUSERNAME/.claude/debug-hook.sh"
```

**Nach Claude-Nutzung, prüfe das Log:**

```bash
cat /tmp/claude-hook-debug.log
```

**Wenn Log leer ist:** Hook wird nicht ausgeführt → Überprüfe Hook-Konfiguration
**Wenn Log Einträge hat:** Hook funktioniert → Problem ist beim Sound-Playback

### Problem: "Error converting path" im Log

**Ursache:** `wslpath` kann den Pfad nicht konvertieren

**Lösung:** Nutze Windows System Sounds statt eigener WAV-Datei:

```json
"soundNotification": "gentle-chime"
```

### Problem: Sound spielt mehrfach

**Ursache:** Stop Hook wird mehrfach getriggert (bekannter Bug in älteren Versionen)

**Lösung 1:** Update Claude Code:

```bash
npm update -g @anthropic-ai/claude-code
```

**Lösung 2:** Temporärer Workaround - Verhindere mehrfaches Abspielen:

```bash
# Modifiziere notify-sound.js und füge ganz oben hinzu:
const lockFile = '/tmp/claude-sound.lock';
if (fs.existsSync(lockFile)) {
  const lockTime = fs.statSync(lockFile).mtimeMs;
  if (Date.now() - lockTime < 500) {
    process.exit(0); // Ignore if sound played < 500ms ago
  }
}
fs.writeFileSync(lockFile, '');
```

---

## Warum funktioniert das jetzt?

### Die häufigsten Fehler:

❌ **Fehler 1:** `Notification` Hook statt `Stop` Hook
- `Notification` triggert nur bei spezifischen Events (idle_prompt, permission_prompt)
- Lösung: `Stop` Hook nutzen

❌ **Fehler 2:** Falsche Pfade in .claude.json
- Tilde `~` wird in .claude.json manchmal nicht expandiert
- Lösung: Absolute Pfade nutzen (`/home/username/...`)

❌ **Fehler 3:** Linux Audio-Tools in WSL
- sox, mpg123, aplay funktionieren NICHT in WSL
- Lösung: PowerShell nutzen für Windows-Audio

❌ **Fehler 4:** Nur eine Config-Datei angelegt
- Manche Claude-Versionen lesen nur `.claude.json`
- Andere nur `settings.json`
- Lösung: Beide anlegen!

### Warum die PowerShell-Lösung funktioniert:

✅ WSL kann Windows-Programme aufrufen (`powershell.exe`)
✅ PowerShell kann Windows System Sounds abspielen
✅ PowerShell kann WAV-Dateien über `System.Media.SoundPlayer` abspielen
✅ Wir konvertieren WSL-Pfade zu Windows-Pfaden mit `wslpath`

---

# Wie funktioniert es?

## Das Hook-System

Claude Code hat ein **Hook-System**, das bei bestimmten Events Befehle ausführt:

1. **Stop Hook** - Wird ausgeführt wenn Claude Code fertig ist und auf Eingabe wartet
2. Der Hook ruft ein **Sound-Script** auf
3. Das Script spielt einen kurzen **Ton**

**Die Komponenten:**
```
Claude Code fertig
   → Stop Hook wird getriggert
   → .claude-synth-3.sh wird ausgeführt
   → Ton wird abgespielt (C7 Note, 0.08 Sekunden)
```

---

# Installation für Termux (Android)

## Schritt 1: Prüfe ob sox installiert ist

```bash
which sox
which play
```

**Mögliche Ergebnisse:**

**Fall A:** Du siehst Pfade (z.B. `/data/data/com.termux/files/usr/bin/sox`)
- ✅ sox ist installiert → Springe zu Schritt 3

**Fall B:** Du siehst nichts oder "not found"
- ❌ sox ist NICHT installiert → Mache Schritt 2

## Schritt 2: Installiere sox

**KRITISCH:** Sound Notifications benötigen das `sox` Package!

```bash
pkg install sox -y
```

**Was passiert:**
- sox wird installiert (Sound eXchange - Audio Tool)
- Dependencies werden installiert (file, libao, libmad, etc.)
- Dauert ca. 10-20 Sekunden

**Verifiziere die Installation:**
```bash
which play && which sox
```

**Erwartete Ausgabe:**
```
/data/data/com.termux/files/usr/bin/play
/data/data/com.termux/files/usr/bin/sox
```

✅ **Wenn du beide Pfade siehst:** sox ist installiert!
❌ **Wenn Fehler:** Wiederhole Schritt 2

## Schritt 3: Erstelle Sound-Scripts

Erstelle die Sound-Synthesis Scripts im Home-Verzeichnis:

**Script 1: Gentle two-note chime (E6 → A6)**
```bash
cat > ~/.claude-synth-1.sh << 'EOF'
#!/bin/bash
play -n synth 0.08 sine 1318 vol 0.3 fade 0 0.08 0.03 2>/dev/null &
sleep 0.1
play -n synth 0.08 sine 1760 vol 0.3 fade 0 0.08 0.03 2>/dev/null &
EOF
chmod +x ~/.claude-synth-1.sh
```

**Script 2: Upward arpeggio (C6 → E6 → G6)**
```bash
cat > ~/.claude-synth-2.sh << 'EOF'
#!/bin/bash
play -n synth 0.06 sine 1046 vol 0.3 fade 0 0.06 0.02 2>/dev/null &
sleep 0.07
play -n synth 0.06 sine 1318 vol 0.3 fade 0 0.06 0.02 2>/dev/null &
sleep 0.07
play -n synth 0.06 sine 1568 vol 0.3 fade 0 0.06 0.02 2>/dev/null &
EOF
chmod +x ~/.claude-synth-2.sh
```

**Script 3: Quick notification ping (C7) - EMPFOHLEN**
```bash
cat > ~/.claude-synth-3.sh << 'EOF'
#!/bin/bash
play -n synth 0.08 sine 2093 vol 0.4 fade 0 0.08 0.03 2>/dev/null &
EOF
chmod +x ~/.claude-synth-3.sh
```

**Script 4: Single soft beep (800Hz)**
```bash
cat > ~/.claude-synth-4.sh << 'EOF'
#!/bin/bash
play -n synth 0.1 sine 800 vol 0.3 fade 0 0.1 0.04 2>/dev/null &
EOF
chmod +x ~/.claude-synth-4.sh
```

**Script 5: Double ascending beep (600Hz → 900Hz)**
```bash
cat > ~/.claude-synth-5.sh << 'EOF'
#!/bin/bash
play -n synth 0.08 sine 600 vol 0.3 fade 0 0.08 0.03 2>/dev/null &
sleep 0.15
play -n synth 0.08 sine 900 vol 0.3 fade 0 0.08 0.03 2>/dev/null &
EOF
chmod +x ~/.claude-synth-5.sh
```

**Script 6: Soft bell-like tone (D6 → F#6)**
```bash
cat > ~/.claude-synth-6.sh << 'EOF'
#!/bin/bash
play -n synth 0.1 sine 1174 vol 0.35 fade 0 0.1 0.05 2>/dev/null &
sleep 0.05
play -n synth 0.1 sine 1480 vol 0.25 fade 0 0.1 0.05 2>/dev/null &
EOF
chmod +x ~/.claude-synth-6.sh
```

## Schritt 4: Teste die Scripts

**Teste Script 3 (Empfohlen):**
```bash
bash ~/.claude-synth-3.sh
```

**Was du hören solltest:** Ein kurzer, klarer Ping-Ton (ca. 0.08 Sekunden)

**Teste alle Scripts:**
```bash
for i in {1..6}; do
  echo "Testing synth-$i..."
  bash ~/.claude-synth-$i.sh
  sleep 1
done
```

**Was passiert:** Alle 6 Sound-Scripts werden nacheinander abgespielt

## Schritt 5: Konfiguriere Claude Code Hook

**Erstelle/Bearbeite die Settings-Datei:**
```bash
mkdir -p ~/.claude
nano ~/.claude/settings.json
```

**Füge diese Konfiguration ein:**
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude-synth-3.sh"
          }
        ]
      }
    ]
  }
}
```

**WICHTIG:**
- Wenn die Datei bereits existiert, füge nur den `hooks` Block hinzu
- Achte auf die korrekte JSON-Syntax (Kommas, Klammern)
- Der `matcher: "*"` bedeutet: Hook gilt für alle Claude-Sessions

**Speichern:**
1. Drücke `Ctrl + O`, dann `Enter`
2. Drücke `Ctrl + X`

## Schritt 6: Teste die Hook-Integration

**Starte Claude Code und teste einen Befehl:**
```bash
claude
```

Wenn Claude fertig ist und auf deine Eingabe wartet, solltest du den Ton hören!

---

# Sound-Scripts wechseln

Du hast 6 verschiedene Sounds zur Auswahl. Um den Sound zu ändern:

**Bearbeite die Settings:**
```bash
nano ~/.claude/settings.json
```

**Ändere die Zeile:**
```json
"command": "$HOME/.claude-synth-3.sh"
```

**Zu einem anderen Script (z.B. Script 1):**
```json
"command": "$HOME/.claude-synth-1.sh"
```

**Verfügbare Scripts:**
- `.claude-synth-1.sh` - Gentle two-note chime (E6 → A6)
- `.claude-synth-2.sh` - Upward arpeggio (C6 → E6 → G6)
- `.claude-synth-3.sh` - Quick notification ping (C7) - **Standard**
- `.claude-synth-4.sh` - Single soft beep (800Hz)
- `.claude-synth-5.sh` - Double ascending beep (600Hz → 900Hz)
- `.claude-synth-6.sh` - Soft bell-like tone (D6 → F#6)

---

# Troubleshooting

## Problem 1: Kein Ton wird abgespielt

**Diagnose:**
```bash
which play
which sox
```

**Lösung A:** `sox` ist nicht installiert
```bash
pkg install sox -y
```

**Lösung B:** Script hat keine Ausführungsrechte
```bash
chmod +x ~/.claude-synth-*.sh
```

**Lösung C:** Teste das Script manuell
```bash
bash ~/.claude-synth-3.sh
```

Wenn der manuelle Test funktioniert, liegt das Problem am Hook.

## Problem 2: Hook wird nicht ausgelöst

**Prüfe die Hook-Logs:**
```bash
cat ~/.claude-hook.log
```

**Erwartete Ausgabe:**
```
[2026-01-10 00:15:34] Hook: Stop
```

**Wenn keine Logs:** Hook-Konfiguration ist fehlerhaft

**Prüfe die Settings:**
```bash
cat ~/.claude/settings.json
```

**Achte auf:**
- ✅ Korrekte JSON-Syntax
- ✅ Richtige Pfade (`$HOME/.claude-synth-3.sh`)
- ✅ Hook-Type ist "command"

## Problem 3: "play: command not found" Error

**Problem:** Das `sox` Package wurde deinstalliert oder ist nicht im PATH

**Lösung:**
```bash
pkg install sox -y
```

**Verifiziere:**
```bash
play --version
```

**Erwartete Ausgabe:**
```
SoX v14.4.2
```

## Problem 4: Ton ist zu laut/leise

**Passe die Lautstärke im Script an:**

```bash
nano ~/.claude-synth-3.sh
```

**Ändere `vol 0.4` zu einem anderen Wert:**
- `vol 0.2` - Leiser
- `vol 0.6` - Lauter
- `vol 0.8` - Sehr laut

**Beispiel:**
```bash
#!/bin/bash
play -n synth 0.08 sine 2093 vol 0.2 fade 0 0.08 0.03 2>/dev/null &
```

## Problem 5: Sound wird mehrfach abgespielt

**Problem:** Das `&` am Ende des play-Befehls fehlt

**Lösung:** Stelle sicher, dass `&` am Ende steht:
```bash
play -n synth 0.08 sine 2093 vol 0.4 fade 0 0.08 0.03 2>/dev/null &
```

Das `&` startet den Befehl im Hintergrund, sodass das Script sofort beendet wird.

---

# Technische Details

## Was macht der play-Befehl?

```bash
play -n synth 0.08 sine 2093 vol 0.4 fade 0 0.08 0.03 2>/dev/null &
```

**Erklärung:**
- `play` - sox command für Audio-Wiedergabe
- `-n` - Nutze "null input" (kein Audio-File, sondern Synthese)
- `synth` - Synthesiere einen Ton
- `0.08` - Dauer: 0.08 Sekunden
- `sine` - Wellenform: Sinuswelle (reiner Ton)
- `2093` - Frequenz: 2093 Hz (Note C7)
- `vol 0.4` - Lautstärke: 40%
- `fade 0 0.08 0.03` - Fade-out am Ende (3ms)
- `2>/dev/null` - Unterdrücke Error-Ausgaben
- `&` - Starte im Hintergrund

## Frequenzen der Noten

**Verwendete Frequenzen:**
- C6: 1046 Hz
- D6: 1174 Hz
- E6: 1318 Hz
- F#6: 1480 Hz
- G6: 1568 Hz
- A6: 1760 Hz
- C7: 2093 Hz
- 600 Hz: Tiefer Beep
- 800 Hz: Standard Beep
- 900 Hz: Hoher Beep

## Hook-Types

Claude Code unterstützt verschiedene Hook-Types:

- **Stop** - Claude wartet auf Eingabe (VERWENDET)
- **PreToolUse** - Vor Tool-Verwendung
- **PostToolUse** - Nach Tool-Verwendung
- **SessionStart** - Bei Session-Start
- **UserPromptSubmit** - Nach User-Eingabe

---

# Zusammenfassung

## Was du brauchst:

1. **sox Package** (Sound eXchange)
   ```bash
   pkg install sox -y
   ```

2. **Sound-Scripts** (`.claude-synth-*.sh`)
   - Im Home-Verzeichnis erstellen
   - Ausführungsrechte setzen

3. **Claude Settings** (`.claude/settings.json`)
   - Stop Hook konfigurieren
   - Script-Pfad angeben

## Quick Setup (Alle Befehle in einem):

```bash
# 1. Installiere sox
pkg install sox -y

# 2. Erstelle Script 3 (Quick ping - Empfohlen)
cat > ~/.claude-synth-3.sh << 'EOF'
#!/bin/bash
play -n synth 0.08 sine 2093 vol 0.4 fade 0 0.08 0.03 2>/dev/null &
EOF
chmod +x ~/.claude-synth-3.sh

# 3. Konfiguriere Hook
mkdir -p ~/.claude
cat > ~/.claude/settings.json << 'EOF'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude-synth-3.sh"
          }
        ]
      }
    ]
  }
}
EOF

# 4. Teste
bash ~/.claude-synth-3.sh
```

## Merke:

- ❌ Sound Notifications sind NICHT standardmäßig aktiv
- ❌ `sox` ist NICHT vorinstalliert in Termux
- ✅ Du MUSST alles selbst einrichten (einmalig)
- Nach dem Setup funktioniert es permanent
- Du kannst jederzeit den Sound wechseln (6 Scripts verfügbar)

---

# Weitere Hook-Beispiele (Optional)

## Sound bei Session-Start

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude-synth-1.sh"
          }
        ]
      }
    ]
  }
}
```

## Mehrere Hooks kombinieren

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude-synth-3.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude-synth-1.sh"
          }
        ]
      }
    ]
  }
}
```

---

# Alternative: System Notification Sounds

Wenn du Android System-Sounds statt synthetisierten Sounds bevorzugst:

**Installiere mpv:**
```bash
pkg install mpv -y
```

**Erstelle Alternative Scripts:**
```bash
cat > ~/.claude-tone-1.sh << 'EOF'
#!/bin/bash
mpv --really-quiet /system/media/audio/notifications/SoundTheme/Calm/Conclusion.ogg 2>/dev/null &
EOF
chmod +x ~/.claude-tone-1.sh
```

**Nutze im Hook:**
```json
"command": "$HOME/.claude-tone-1.sh"
```

**WICHTIG:** Verfügbarkeit von System-Sounds hängt von deinem Android-Gerät ab!
