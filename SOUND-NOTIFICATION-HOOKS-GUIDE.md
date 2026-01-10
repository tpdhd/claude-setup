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
