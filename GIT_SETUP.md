# Git Setup für Claude Code (WSL/Termux)

## Git-Konfiguration

```bash
# Benutzerdaten setzen
git config --global user.name "Dein Name"
git config --global user.email "deine@email.de"

# Konfiguration prüfen
git config --list
```

## SSH-Key für GitHub/GitLab

### 1. SSH-Key generieren

```bash
# ED25519 Key (empfohlen)
ssh-keygen -t ed25519 -C "deine@email.de"

# Oder RSA (falls ed25519 nicht unterstützt)
ssh-keygen -t rsa -b 4096 -C "deine@email.de"

# Standard-Speicherort: ~/.ssh/id_ed25519 oder ~/.ssh/id_rsa
```

### 2. SSH-Agent starten (Termux)

```bash
# SSH-Agent starten
eval "$(ssh-agent -s)"

# Key hinzufügen
ssh-add ~/.ssh/id_ed25519
```

### 3. Public Key zu GitHub/GitLab hinzufügen

```bash
# Public Key anzeigen und kopieren
cat ~/.ssh/id_ed25519.pub

# Dann auf GitHub: Settings → SSH and GPG keys → New SSH key
```

### 4. SSH-Verbindung testen

```bash
# GitHub
ssh -T git@github.com

# GitLab
ssh -T git@gitlab.com
```

## Repository-Operationen

### Neues Repo erstellen und pushen

```bash
# Lokal initialisieren
git init
git add .
git commit -m "Initial commit"

# Remote hinzufügen (SSH)
git remote add origin git@github.com:username/repo.git

# Oder HTTPS (benötigt Personal Access Token)
git remote add origin https://github.com/username/repo.git

# Branch setzen und pushen
git branch -M main
git push -u origin main
```

### Bestehendes Repo klonen

```bash
# SSH (empfohlen)
git clone git@github.com:username/repo.git

# HTTPS
git clone https://github.com/username/repo.git
```

## Termux-spezifische Hinweise

```bash
# Git installieren (falls nicht vorhanden)
pkg install git openssh

# SSH-Verzeichnis erstellen
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

## WSL-spezifische Hinweise

### SSH-Keys von Windows teilen (optional)

```bash
# Windows SSH-Keys nach WSL kopieren
cp /mnt/c/Users/USERNAME/.ssh/id_ed25519* ~/.ssh/
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Git Credential Helper

```bash
# Git Credential Manager aus Windows nutzen
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"

# Oder: WSL eigenen Credential Helper
git config --global credential.helper cache
```

## GitHub CLI (gh) - Alternative

```bash
# Termux
pkg install gh

# WSL
# Siehe: https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# Authentifizierung
gh auth login

# Repo erstellen und pushen
gh repo create
git push -u origin main
```

## Troubleshooting

### Permission denied (publickey)

```bash
# SSH-Agent läuft?
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Permissions korrekt?
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh
```

### HTTPS: Authentication failed

```bash
# Personal Access Token erstellen (GitHub Settings → Developer settings → Personal access tokens)
# Bei git push Username + Token (statt Passwort) eingeben

# Oder SSH verwenden (siehe oben)
git remote set-url origin git@github.com:username/repo.git
```
