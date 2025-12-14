# Claude Code Installation

## Termux (Android)

```bash
# Node.js & npm installieren
pkg install nodejs-lts

# Claude Code installieren
npm install -g @anthropic-ai/claude-code

# Verifizieren
claude --version
```

## Linux (Debian/Ubuntu)

**Option 1: Einfach (empfohlen für Anfänger)**
```bash
# Node.js & npm aus Ubuntu-Repository
sudo apt update
sudo apt install -y nodejs npm

# Claude Code installieren
npm install -g @anthropic-ai/claude-code

# Verifizieren
claude --version
```

**Option 2: Neueste LTS (für aktuelle Version)**
```bash
# NodeSource Repository hinzufügen (benötigt curl)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Claude Code installieren
npm install -g @anthropic-ai/claude-code
```

## macOS

```bash
# Node.js & npm installieren (via Homebrew)
brew install node

# Claude Code installieren
npm install -g @anthropic-ai/claude-code

# Verifizieren
claude --version
```

## WSL (Windows Subsystem for Linux)

**Option 1: Einfach (empfohlen)**
```bash
# Node.js & npm installieren
sudo apt update
sudo apt install -y nodejs npm

# Claude Code installieren
npm install -g @anthropic-ai/claude-code

# Verifizieren
claude --version
```

**Option 2: Neueste LTS**
```bash
# NodeSource Repository (benötigt curl)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Claude Code installieren
npm install -g @anthropic-ai/claude-code
```

## Erste Schritte

```bash
# Claude starten
claude

# Mit dangerously skip permissions
claude --dsp

# In spezifischem Verzeichnis
cd /path/to/project
claude --dsp
```

## Updates

```bash
# Claude Code aktualisieren
npm update -g @anthropic-ai/claude-code

# Oder: Auto-Update aktivieren (empfohlen)
# Wird beim Start automatisch durchgeführt
```
