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

```bash
# Node.js & npm installieren
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Claude Code installieren
npm install -g @anthropic-ai/claude-code

# Verifizieren
claude --version
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

```bash
# Node.js & npm installieren
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Claude Code installieren
npm install -g @anthropic-ai/claude-code

# Verifizieren
claude --version
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
