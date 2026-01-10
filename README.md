# Claude Code Setup
Complete setup guide for Claude Code including installation, Git configuration, commands, sound notification hooks, and Windows-specific integrations. Essential resource for new Claude instances on Termux/WSL/Linux/Windows.

## ⚡ Quick Start: Permanent --dsp Flag

Add a permanent `--dsp` shorthand for `--dangerously-skip-permissions` that survives all npm updates:

```bash
# One-line installation
bash <(curl -s https://raw.githubusercontent.com/tpdhd/claude-setup/master/install-dsp-flag.sh)

# Or run locally
./install-dsp-flag.sh
```

After installation, use `claude --dsp` instead of `claude --dangerously-skip-permissions`. See **[DSP-FLAG-GUIDE.md](./DSP-FLAG-GUIDE.md)** for complete documentation.

## 📁 Contents

### Core Setup
- **[INSTALL.md](./INSTALL.md)** - Claude Code Installation für alle Plattformen
- **[GIT_SETUP.md](./GIT_SETUP.md)** - Git Konfiguration und Hooks
- **[COMMANDS.md](./COMMANDS.md)** - Nützliche Befehle und Shortcuts

### Plugins & Extensions
- **[GSD-INSTALLATION-GUIDE.md](./GSD-INSTALLATION-GUIDE.md)** - 🚀 Get Shit Done (GSD) Plugin Installation & Troubleshooting

### Platform-Specific
- **[SOUND-SETUP.md](./SOUND-SETUP.md)** - 🔊 Sound Notification Hooks für Termux/Android
- **[DSP-FLAG-GUIDE.md](./DSP-FLAG-GUIDE.md)** - Complete --dsp flag guide (installation, troubleshooting, all methods)
- **[install-dsp-flag.sh](./install-dsp-flag.sh)** - Automated installer for --dsp flag
- **[verify-dsp.sh](./verify-dsp.sh)** - Verification script for --dsp flag
- **[WINDOWS-CURSOR-EXPLORER.md](./WINDOWS-CURSOR-EXPLORER.md)** - 🪟 Windows: Cursor aus Explorer Adresszeile starten (ohne CMD-Fenster)
- **[sound-hooks/](./sound-hooks/)** - Sound notification scripts (.claude-synth-*.sh, .claude-tone-*.sh)
