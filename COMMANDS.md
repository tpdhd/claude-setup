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

**Bash/Zsh (~/.bashrc oder ~/.zshrc):**
```bash
alias c='claude --dsp'
alias cdsp='claude --dsp'
```

**Fish (~/.config/fish/config.fish):**
```fish
alias c='claude --dsp'
alias cdsp='claude --dsp'
```

Nach dem Hinzufügen:
```bash
source ~/.bashrc  # oder ~/.zshrc / ~/.config/fish/config.fish
```

Dann kannst du einfach verwenden:
```bash
c              # Statt: claude --dsp
cdsp           # Statt: claude --dsp
```
