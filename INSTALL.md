# Claude Code Installation - Einfache Anleitung

## Was ist Claude Code?

Claude Code ist ein Terminal-Programm, das du installieren musst.

**WICHTIG:**
- ❌ Claude Code ist NICHT standardmäßig installiert
- ❌ Einfach "claude" tippen funktioniert NICHT ohne Installation
- ✅ Du MUSST Claude Code erst installieren (siehe unten)

## Was du brauchst

Um Claude Code zu installieren, brauchst du:
1. **Node.js** (JavaScript Runtime)
2. **npm** (Package Manager für Node.js)

**WICHTIG:**
- ❌ Node.js und npm sind NICHT standardmäßig installiert
- ✅ Du musst sie ZUERST installieren (siehe unten)

---

# Installation für WSL (Windows Subsystem for Linux)

## Schritt 1: Prüfe ob Node.js bereits installiert ist

```bash
node --version
```

**Mögliche Ergebnisse:**

**Fall A:** Du siehst eine Version (z.B. `v20.11.0`)
- ✅ Node.js ist installiert → Springe zu Schritt 3

**Fall B:** Du siehst `command not found`
- ❌ Node.js ist NICHT installiert → Mache Schritt 2

## Schritt 2: Installiere Node.js und npm

**Einfache Methode (empfohlen):**

```bash
sudo apt update
```
**Was passiert:** System aktualisiert Paketliste

```bash
sudo apt install -y nodejs npm
```
**Was passiert:** Node.js und npm werden installiert

**Verifiziere die Installation:**
```bash
node --version
npm --version
```

**Erwartete Ausgabe:**
```
v18.19.0    (oder höher)
9.2.0       (oder höher)
```

✅ **Wenn du Versionen siehst:** Installation erfolgreich!
❌ **Wenn Fehler:** Wiederhole Schritt 2

## Schritt 3: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

**Was passiert:**
- npm lädt Claude Code herunter
- `-g` bedeutet "global" = überall verfügbar
- Dauert 1-2 Minuten

**Erwartete Ausgabe:**
```
added 523 packages in 45s
```

## Schritt 4: Verifiziere Claude Code Installation

```bash
claude --version
```

**Erwartete Ausgabe:**
```
2.0.69    (oder höher)
```

✅ **Wenn du eine Version siehst:** Claude Code ist installiert!
❌ **Wenn `command not found`:** Wiederhole Schritt 3

## Schritt 5: Starte Claude Code

```bash
claude
```

**Was passiert:** Claude Code startet im interaktiven Modus

---

# Installation für Linux (Debian/Ubuntu)

## Schritt 1: Prüfe ob Node.js installiert ist

```bash
node --version
```

**Fall A:** Version wird angezeigt → Springe zu Schritt 3
**Fall B:** `command not found` → Mache Schritt 2

## Schritt 2: Installiere Node.js und npm

```bash
sudo apt update
sudo apt install -y nodejs npm
```

**Verifiziere:**
```bash
node --version
npm --version
```

## Schritt 3: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

## Schritt 4: Verifiziere

```bash
claude --version
```

## Schritt 5: Starte Claude

```bash
claude
```

---

# Installation für Arch Linux

## Schritt 1: Prüfe ob Node.js installiert ist

```bash
node --version
```

**Fall A:** Version wird angezeigt → Springe zu Schritt 3
**Fall B:** `command not found` → Mache Schritt 2

## Schritt 2: Installiere Node.js und npm

**Methode mit pacman (empfohlen):**

```bash
sudo pacman -Syu
```
**Was passiert:** System wird aktualisiert

```bash
sudo pacman -S nodejs npm
```
**Was passiert:** Node.js und npm werden installiert

**Verifiziere die Installation:**
```bash
node --version
npm --version
```

**Erwartete Ausgabe:**
```
v20.10.0    (oder höher)
10.2.0      (oder höher)
```

✅ **Wenn du Versionen siehst:** Installation erfolgreich!
❌ **Wenn Fehler:** Wiederhole Schritt 2

## Schritt 3: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

**Was passiert:**
- npm lädt Claude Code herunter
- `-g` bedeutet "global" = überall verfügbar
- Dauert 1-2 Minuten

**Erwartete Ausgabe:**
```
added 523 packages in 45s
```

## Schritt 4: Verifiziere Claude Code Installation

```bash
claude --version
```

**Erwartete Ausgabe:**
```
2.0.69    (oder höher)
```

✅ **Wenn du eine Version siehst:** Claude Code ist installiert!
❌ **Wenn `command not found`:** Wiederhole Schritt 3

## Schritt 5: Starte Claude Code

```bash
claude
```

**Was passiert:** Claude Code startet im interaktiven Modus

---

# Installation für Termux (Android)

## Schritt 1: Prüfe ob Node.js installiert ist

```bash
node --version
```

**Fall A:** Version wird angezeigt → Springe zu Schritt 3
**Fall B:** `command not found` → Mache Schritt 2

## Schritt 2: Installiere Node.js

```bash
pkg install nodejs-lts
```

**Was passiert:** Node.js LTS wird installiert (beinhaltet npm)

**Verifiziere:**
```bash
node --version
npm --version
```

## Schritt 3: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

## Schritt 4: Verifiziere

```bash
claude --version
```

## Schritt 5: Starte Claude

```bash
claude
```

---

# Installation für Ubuntu on Android (Userland)

## Problem: Veraltete Versionen

Ubuntu auf Android (via Userland) hat oft **sehr alte** Node.js Versionen in den Standard-Repositories:

```bash
sudo apt install nodejs npm
node --version
# Ausgabe: v10.19.0  ❌ ZU ALT!
```

**WICHTIG:** Diese alten Versionen funktionieren NICHT mit Claude Code!

## Lösung 1: NodeSource Repository (Empfohlen)

Diese Methode installiert die neueste offizielle Node.js Version.

### Schritt 1: Installiere curl

```bash
sudo apt-get update
sudo apt-get install -y curl
```

### Schritt 2: Füge NodeSource Repository hinzu und installiere Node.js

**Für Node.js 20.x (LTS - Empfohlen):**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

**Oder für Node.js 22.x (Neueste Version):**
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Schritt 3: Verifiziere Installation

```bash
node --version
npm --version
```

**Erwartete Ausgabe:**
```
v20.11.0    (oder höher) ✅
10.2.4      (oder höher) ✅
```

### Schritt 4: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### Schritt 5: Verifiziere und starte

```bash
claude --version
claude
```

---

## Lösung 2: nvm (Node Version Manager)

Diese Methode erlaubt das Installieren und Wechseln zwischen mehreren Node.js Versionen.

### Schritt 1: Installiere nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

### Schritt 2: Lade Shell-Konfiguration neu

```bash
source ~/.bashrc
```

**Oder schließe das Terminal und öffne es neu.**

### Schritt 3: Installiere Node.js mit nvm

**Neueste LTS Version (Empfohlen):**
```bash
nvm install --lts
```

**Oder spezifische Version:**
```bash
nvm install 20
```

### Schritt 4: Setze Default-Version

```bash
nvm alias default 20
```

### Schritt 5: Verifiziere Installation

```bash
node --version
npm --version
```

**Erwartete Ausgabe:**
```
v20.11.0    (oder höher) ✅
10.2.4      (oder höher) ✅
```

### Schritt 6: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### Schritt 7: Verifiziere und starte

```bash
claude --version
claude
```

---

## nvm Zusatz-Befehle (Optional)

Wenn du nvm verwendest, kannst du zwischen Node.js Versionen wechseln:

**Liste installierte Versionen:**
```bash
nvm list
```

**Liste verfügbare Versionen:**
```bash
nvm list-remote
```

**Wechsle zu anderer Version:**
```bash
nvm use 18
nvm use 20
```

**Installiere weitere Version:**
```bash
nvm install 18
```

---

# Installation für macOS

## Schritt 1: Prüfe ob Homebrew installiert ist

```bash
brew --version
```

**Fall A:** Version wird angezeigt → Gehe zu Schritt 2
**Fall B:** `command not found` → Installiere Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Schritt 2: Prüfe ob Node.js installiert ist

```bash
node --version
```

**Fall A:** Version wird angezeigt → Springe zu Schritt 4
**Fall B:** `command not found` → Mache Schritt 3

## Schritt 3: Installiere Node.js

```bash
brew install node
```

**Verifiziere:**
```bash
node --version
npm --version
```

## Schritt 4: Installiere Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

## Schritt 5: Verifiziere

```bash
claude --version
```

## Schritt 6: Starte Claude

```bash
claude
```

---

# Erste Schritte nach Installation

## Test 1: Starte Claude normal

```bash
claude
```

**Was passiert:** Claude startet und fragt nach Login

## Test 2: Starte Claude mit vollem Befehl

```bash
claude --dangerously-skip-permissions
```

**Was passiert:** Claude startet ohne Berechtigungsfragen

## Test 3: Zeige Version

```bash
claude --version
```

**Was passiert:** Zeigt installierte Version

## Test 4: Zeige Hilfe

```bash
claude --help
```

**Was passiert:** Zeigt alle verfügbaren Befehle

---

# Updates

## Wann updaten?

Claude Code zeigt automatisch, wenn ein Update verfügbar ist.

## Wie updaten?

```bash
npm update -g @anthropic-ai/claude-code
```

**Was passiert:** Claude Code wird auf neueste Version aktualisiert

**Verifiziere neues Update:**
```bash
claude --version
```

---

# Häufige Fehler

## Fehler 1: "npm: command not found"

**Problem:** npm ist nicht installiert

**Lösung:** Installiere Node.js und npm (siehe Schritt 2 deines Systems oben)

## Fehler 2: "permission denied" beim npm install

**Problem:** Fehlende Berechtigungen

**Lösung für Linux/WSL:**
```bash
sudo npm install -g @anthropic-ai/claude-code
```

**Lösung für Termux:**
Kein `sudo` nötig - installiere ohne `sudo`

## Fehler 3: "claude: command not found" nach Installation

**Problem 1:** npm global bin Pfad nicht in PATH

**Lösung - Finde npm bin Pfad:**
```bash
npm config get prefix
```

**Erwartete Ausgabe (z.B.):**
```
/home/username/.npm-global
```

**Füge zu PATH hinzu:**
```bash
echo 'export PATH="$PATH:/home/username/.npm-global/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Ersetze** `/home/username/.npm-global` mit deiner tatsächlichen Ausgabe!

**Problem 2:** Terminal nicht neu gestartet

**Lösung:** Schließe Terminal und öffne neu

## Fehler 4: Installation hängt oder ist sehr langsam

**Problem:** Netzwerkverbindung oder npm Cache

**Lösung:**
```bash
npm cache clean --force
npm install -g @anthropic-ai/claude-code
```

---

# Zusammenfassung

## Was du installiert haben musst (in Reihenfolge):

1. **Node.js** → JavaScript Runtime
   - Prüfen: `node --version`
   - Installieren: Siehe Schritt 2 deines Systems

2. **npm** → Package Manager (kommt meist mit Node.js)
   - Prüfen: `npm --version`
   - Kommt automatisch mit Node.js

3. **Claude Code** → Das Terminal-Programm
   - Installieren: `npm install -g @anthropic-ai/claude-code`
   - Prüfen: `claude --version`

## Wenn alles installiert ist:

```bash
claude                                    # Starten
claude --dangerously-skip-permissions     # Starten ohne Berechtigungsfragen
claude --version                          # Version anzeigen
```

## Merke:

- ❌ Nichts davon ist standardmäßig installiert
- ✅ Du musst ALLES selbst installieren (Schritt für Schritt oben)
- Die Installation ist **einmalig** pro System
- Nach der Installation bleibt Claude Code permanent verfügbar
