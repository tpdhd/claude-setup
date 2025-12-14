# Commands

## Dangerously Skip Permissions Mode

### Verwendung

**Standard-Befehl (eingebaut):**
```bash
claude --dangerously-skip-permissions
```

**Kurzform `--dsp` (muss selbst erstellt werden):**
```bash
claude --dsp
```

**⚠️ WICHTIG: `--dsp` ist NICHT standardmäßig verfügbar!**

- ❌ `claude --dsp` funktioniert **NICHT** out-of-the-box
- ✅ Nur `claude --dangerously-skip-permissions` ist eingebaut
- 🛠️ `--dsp` ist ein **Shell-Alias**, den du **selbst erstellen musst**
- Diese Anleitung zeigt, wie du die Kurzform `--dsp` in deine CLI einbaust

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

### Shell-Alias erstellen (ERFORDERLICH für --dsp)

**So erstellst du die Kurzform `--dsp`:**

Die folgenden Anleitungen zeigen, wie du `claude --dsp` als Alias einrichtest, damit du nicht jedes Mal den langen Befehl `claude --dangerously-skip-permissions` tippen musst.

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

# Diese Zeile hinzufügen (WICHTIG: Den vollen Befehl verwenden!):
alias dsp='claude --dangerously-skip-permissions'

# Optional: Weitere Kurzformen
alias c='claude --dangerously-skip-permissions'
alias cdsp='claude --dangerously-skip-permissions'

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
alias dsp='claude --dangerously-skip-permissions'
alias c='claude --dangerously-skip-permissions'
alias cdsp='claude --dangerously-skip-permissions'

# Speichern: Ctrl+O, Enter, dann Ctrl+X

# Aktivieren
source ~/.bashrc
```

**3. Testen:**
```bash
# Neues Terminal öffnen oder:
source ~/.bashrc

# Jetzt funktioniert die Kurzform:
dsp            # = claude --dangerously-skip-permissions
c              # = claude --dangerously-skip-permissions
cdsp           # = claude --dangerously-skip-permissions

# Verifizieren:
type dsp       # Sollte zeigen: dsp is aliased to `claude --dangerously-skip-permissions'
```

**Hinweise für WSL:**
- Die .bashrc liegt unter: `~/.bashrc` bzw. `/home/DEIN_USERNAME/.bashrc`
- Windows-Pfad: `C:\Users\WINDOWS_USER\AppData\Local\Packages\...\LocalState\rootfs\home\USERNAME\.bashrc`
- WSL führt `.bashrc` automatisch bei jedem Terminal-Start aus
- `.bash_profile` wird in WSL **nicht** ausgeführt - nur `.bashrc` verwenden

#### Linux (Bash/Zsh)

**Bash (~/.bashrc):**
```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.bashrc
echo "alias c='claude --dangerously-skip-permissions'" >> ~/.bashrc
echo "alias cdsp='claude --dangerously-skip-permissions'" >> ~/.bashrc
source ~/.bashrc
```

**Zsh (~/.zshrc):**
```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.zshrc
echo "alias c='claude --dangerously-skip-permissions'" >> ~/.zshrc
echo "alias cdsp='claude --dangerously-skip-permissions'" >> ~/.zshrc
source ~/.zshrc
```

#### macOS

**Bash (~/.bash_profile oder ~/.bashrc):**
```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.bash_profile
echo "alias c='claude --dangerously-skip-permissions'" >> ~/.bash_profile
echo "alias cdsp='claude --dangerously-skip-permissions'" >> ~/.bash_profile
source ~/.bash_profile
```

**Zsh (~/.zshrc) - Standard ab macOS Catalina:**
```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.zshrc
echo "alias c='claude --dangerously-skip-permissions'" >> ~/.zshrc
echo "alias cdsp='claude --dangerously-skip-permissions'" >> ~/.zshrc
source ~/.zshrc
```

#### Termux (Android)

**Bash (~/.bashrc):**
```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.bashrc
echo "alias c='claude --dangerously-skip-permissions'" >> ~/.bashrc
echo "alias cdsp='claude --dangerously-skip-permissions'" >> ~/.bashrc
source ~/.bashrc
```

#### Fish Shell (~/.config/fish/config.fish)

```fish
# Für alle Plattformen
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.config/fish/config.fish
echo "alias c='claude --dangerously-skip-permissions'" >> ~/.config/fish/config.fish
echo "alias cdsp='claude --dangerously-skip-permissions'" >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

#### Verwendung nach Setup

Nach der Einrichtung kannst du die Kurzformen verwenden:

```bash
dsp            # = claude --dangerously-skip-permissions
c              # = claude --dangerously-skip-permissions
cdsp           # = claude --dangerously-skip-permissions

# Beispiele:
dsp            # Startet Claude im dangerously-skip-permissions Modus
c --version    # Claude Version anzeigen
cdsp           # Alternativer Alias
```

**Hinweis:** Ohne diese Alias-Einrichtung musst du den vollen Befehl verwenden:
```bash
claude --dangerously-skip-permissions
```
