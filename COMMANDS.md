# Commands

## Dangerously Skip Permissions Mode

### Verwendung

```bash
claude --dsp
```

**Was ist `--dsp`?**
- `--dsp` ist eine **eingebaute Kurzform** in Claude Code
- Vollständiger Befehl: `claude --dangerously-skip-permissions`
- **Kein manuelles Setup nötig** - funktioniert sofort nach Claude Code Installation

### Funktion

Startet Claude Code im bypass permissions mode:
- ✅ Überspringt alle Tool-Berechtigungsabfragen
- ✅ Claude kann alle Tools ohne Nachfrage verwenden
- ✅ Schnellerer Workflow in vertrauenswürdigen Projekten

### ⚠️ Sicherheitshinweis

**Nur in vertrauenswürdigen Umgebungen verwenden!**
- Claude erhält uneingeschränkten Zugriff auf:
  - Dateisystem (lesen, schreiben, löschen)
  - Shell-Befehle (bash, git, npm, etc.)
  - Netzwerkzugriff (curl, wget, etc.)

### Optional: Shell-Alias erstellen

Falls du einen kürzeren Alias möchtest:

#### WSL (Windows Subsystem for Linux) - Detailliert

**1. Aktuelle Shell prüfen:**
```bash
echo $SHELL
# Ausgabe: /bin/bash (Standard) oder /bin/zsh
```

**2a. Methode: .bash_aliases verwenden (empfohlen)**

Diese Methode ist sauberer, da .bashrc nicht direkt bearbeitet wird:

```bash
# .bash_aliases erstellen/öffnen
nano ~/.bash_aliases

# Diese Zeilen hinzufügen:
alias c='claude --dsp'
alias cdsp='claude --dsp'

# Speichern: Ctrl+O, Enter, dann Ctrl+X

# Aktivieren
source ~/.bashrc
```

**2b. Alternative: Direkt in .bashrc**

```bash
# .bashrc öffnen
nano ~/.bashrc

# Ans Ende der Datei hinzufügen:
# Claude Code Aliases
alias c='claude --dsp'
alias cdsp='claude --dsp'

# Speichern: Ctrl+O, Enter, dann Ctrl+X

# Aktivieren
source ~/.bashrc
```

**3. Testen:**
```bash
# Neues Terminal öffnen oder:
source ~/.bashrc

# Testen
c --version    # Sollte Claude Code Version anzeigen
```

**Hinweise für WSL:**
- Die .bashrc liegt unter: `~/.bashrc` bzw. `/home/DEIN_USERNAME/.bashrc`
- Windows-Pfad: `C:\Users\WINDOWS_USER\AppData\Local\Packages\...\LocalState\rootfs\home\USERNAME\.bashrc`
- WSL führt `.bashrc` automatisch bei jedem Terminal-Start aus
- `.bash_profile` wird in WSL **nicht** ausgeführt - nur `.bashrc` verwenden

#### Linux (Bash/Zsh)

**Bash (~/.bashrc):**
```bash
echo "alias c='claude --dsp'" >> ~/.bashrc
echo "alias cdsp='claude --dsp'" >> ~/.bashrc
source ~/.bashrc
```

**Zsh (~/.zshrc):**
```bash
echo "alias c='claude --dsp'" >> ~/.zshrc
echo "alias cdsp='claude --dsp'" >> ~/.zshrc
source ~/.zshrc
```

#### macOS

**Bash (~/.bash_profile oder ~/.bashrc):**
```bash
echo "alias c='claude --dsp'" >> ~/.bash_profile
echo "alias cdsp='claude --dsp'" >> ~/.bash_profile
source ~/.bash_profile
```

**Zsh (~/.zshrc) - Standard ab macOS Catalina:**
```bash
echo "alias c='claude --dsp'" >> ~/.zshrc
echo "alias cdsp='claude --dsp'" >> ~/.zshrc
source ~/.zshrc
```

#### Termux (Android)

**Bash (~/.bashrc):**
```bash
echo "alias c='claude --dsp'" >> ~/.bashrc
echo "alias cdsp='claude --dsp'" >> ~/.bashrc
source ~/.bashrc
```

#### Fish Shell (~/.config/fish/config.fish)

```fish
# Für alle Plattformen
echo "alias c='claude --dsp'" >> ~/.config/fish/config.fish
echo "alias cdsp='claude --dsp'" >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

#### Verwendung nach Setup

```bash
c              # Statt: claude --dsp
cdsp           # Statt: claude --dsp
c --version    # Claude Version anzeigen
```
