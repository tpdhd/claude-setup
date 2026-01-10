# Git Setup - Einfache Anleitung

## Was ist Git?

Git ist ein Versionskontroll-System für Code.

**WICHTIG:**
- ✅ Git ist in WSL/Linux/macOS meist VORINSTALLIERT
- ❌ Git-Konfiguration (Name, Email) ist NICHT voreingestellt
- ❌ SSH-Keys sind NICHT erstellt
- ✅ Du MUSST Git erst konfigurieren (siehe unten)

---

# Schritt 1: Prüfe ob Git installiert ist

```bash
git --version
```

**Mögliche Ergebnisse:**

**Fall A:** Du siehst eine Version (z.B. `git version 2.39.0`)
- ✅ Git ist installiert → Gehe zu Schritt 3

**Fall B:** Du siehst `command not found`
- ❌ Git ist NICHT installiert → Mache Schritt 2

---

# Schritt 2: Installiere Git (falls nicht vorhanden)

## Für WSL/Linux (Debian/Ubuntu):

```bash
sudo apt update
sudo apt install -y git
```

**Verifiziere:**
```bash
git --version
```

## Für Termux:

```bash
pkg install git openssh
```

**Verifiziere:**
```bash
git --version
```

## Für macOS:

```bash
brew install git
```

**Verifiziere:**
```bash
git --version
```

---

# Schritt 3: Konfiguriere Git (ERFORDERLICH)

## Was wird konfiguriert?

Git braucht deinen Namen und Email für Commits.

**WICHTIG:**
- ❌ Diese Daten sind NICHT voreingestellt
- ✅ Du MUSST sie selbst setzen
- Diese Daten erscheinen in allen Git-Commits

## Setze deinen Namen

```bash
git config --global user.name "Dein Name"
```

**WICHTIG:** Ersetze `"Dein Name"` mit deinem echten Namen!

**Beispiel:**
```bash
git config --global user.name "Max Mustermann"
```

## Setze deine Email

```bash
git config --global user.email "deine@email.de"
```

**WICHTIG:** Ersetze `"deine@email.de"` mit deiner echten Email!

**Beispiel:**
```bash
git config --global user.email "max@beispiel.de"
```

## Prüfe die Konfiguration

```bash
git config --list
```

**Erwartete Ausgabe (unter anderem):**
```
user.name=Max Mustermann
user.email=max@beispiel.de
```

✅ **Wenn du deine Daten siehst:** Konfiguration erfolgreich!
❌ **Wenn leer:** Wiederhole die Schritte oben

---

# Schritt 4: SSH-Key erstellen (für GitHub/GitLab)

## Warum SSH-Keys?

SSH-Keys erlauben dir, mit GitHub/GitLab zu arbeiten ohne jedes Mal Passwort einzugeben.

**WICHTIG:**
- ❌ SSH-Keys sind NICHT automatisch erstellt
- ✅ Du MUSST sie selbst erstellen
- Einmalig pro Computer

## Prüfe ob SSH-Key bereits existiert

```bash
ls -la ~/.ssh/id_ed25519.pub
```

**Fall A:** Datei wird angezeigt
- ✅ SSH-Key existiert bereits → Gehe zu Schritt 5

**Fall B:** "No such file or directory"
- ❌ Kein SSH-Key → Erstelle einen (siehe unten)

## Erstelle SSH-Key

```bash
ssh-keygen -t ed25519 -C "deine@email.de"
```

**WICHTIG:** Ersetze `"deine@email.de"` mit deiner echten Email!

**Was passiert:**
1. Du wirst gefragt: "Enter file in which to save the key"
   - **Drücke einfach Enter** (nutzt Standard-Pfad)

2. Du wirst gefragt: "Enter passphrase"
   - **Entweder:** Drücke Enter (kein Passwort)
   - **Oder:** Gib ein Passwort ein (sicherer)

3. Du wirst gefragt: "Enter same passphrase again"
   - **Wiederhole** deine Wahl von oben

**Erwartete Ausgabe:**
```
Your identification has been saved in /home/username/.ssh/id_ed25519
Your public key has been saved in /home/username/.ssh/id_ed25519.pub
```

✅ **Wenn du das siehst:** SSH-Key wurde erstellt!

## Verifiziere SSH-Key

```bash
ls -la ~/.ssh/
```

**Erwartete Ausgabe:**
```
id_ed25519          (privater Key - NIEMALS teilen!)
id_ed25519.pub      (öffentlicher Key - für GitHub/GitLab)
```

---

# Schritt 5: SSH-Agent starten (Termux/Linux)

## Warum SSH-Agent?

Der SSH-Agent merkt sich deinen SSH-Key, damit du ihn nicht jedes Mal laden musst.

## Starte SSH-Agent

```bash
eval "$(ssh-agent -s)"
```

**Erwartete Ausgabe:**
```
Agent pid 12345
```

## Füge SSH-Key zum Agent hinzu

```bash
ssh-add ~/.ssh/id_ed25519
```

**Erwartete Ausgabe:**
```
Identity added: /home/username/.ssh/id_ed25519
```

---

# Schritt 6: SSH-Key zu GitHub/GitLab hinzufügen

## Schritt 6.1: Zeige deinen Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

**Erwartete Ausgabe:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... deine@email.de
```

**WICHTIG:** Kopiere die GESAMTE Ausgabe (die ganze Zeile)!

## Schritt 6.2: Für GitHub

1. Gehe zu: https://github.com/settings/keys
2. Klicke: "New SSH key"
3. **Title:** Gib einen Namen ein (z.B. "Mein WSL")
4. **Key:** Füge den kopierten Key ein (aus Schritt 6.1)
5. Klicke: "Add SSH key"

## Schritt 6.3: Für GitLab

1. Gehe zu: https://gitlab.com/-/profile/keys
2. **Key:** Füge den kopierten Key ein
3. **Title:** Gib einen Namen ein (z.B. "Mein WSL")
4. Klicke: "Add key"

---

# Schritt 7: Teste die SSH-Verbindung

## Teste GitHub

```bash
ssh -T git@github.com
```

**Beim ersten Mal wirst du gefragt:**
```
Are you sure you want to continue connecting (yes/no)?
```
**Tippe:** `yes` und drücke Enter

**Erwartete Ausgabe (Erfolg):**
```
Hi USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

✅ **Wenn du das siehst:** GitHub SSH funktioniert!
❌ **Wenn "Permission denied":** SSH-Key nicht richtig hinzugefügt (wiederhole Schritt 6)

## Teste GitLab

```bash
ssh -T git@gitlab.com
```

**Erwartete Ausgabe (Erfolg):**
```
Welcome to GitLab, @USERNAME!
```

---

# Repository-Operationen

## Neues lokales Repository erstellen

```bash
cd /pfad/zu/deinem/projekt
git init
```

**Was passiert:** Git-Repository wird im aktuellen Ordner erstellt

**Erwartete Ausgabe:**
```
Initialized empty Git repository in /pfad/zu/deinem/projekt/.git/
```

## Dateien zum Repository hinzufügen

```bash
git add .
```

**Was passiert:** Alle Dateien im Ordner werden zur Staging Area hinzugefügt

## Ersten Commit erstellen

```bash
git commit -m "Initial commit"
```

**Was passiert:** Erste Version wird gespeichert

**Erwartete Ausgabe:**
```
[main (root-commit) abc1234] Initial commit
 5 files changed, 100 insertions(+)
```

## Remote Repository verbinden

**WICHTIG:** Erstelle zuerst ein Repository auf GitHub/GitLab!

```bash
git remote add origin git@github.com:USERNAME/REPO-NAME.git
```

**WICHTIG:** Ersetze:
- `USERNAME` mit deinem GitHub-Benutzernamen
- `REPO-NAME` mit dem Namen deines Repositories

**Beispiel:**
```bash
git remote add origin git@github.com:maxmustermann/mein-projekt.git
```

## Branch auf "main" setzen

```bash
git branch -M main
```

**Was passiert:** Haupt-Branch wird "main" genannt

## Zum Remote Repository pushen

```bash
git push -u origin main
```

**Was passiert:** Code wird zu GitHub/GitLab hochgeladen

**Erwartete Ausgabe:**
```
Enumerating objects: 5, done.
...
To github.com:USERNAME/REPO-NAME.git
 * [new branch]      main -> main
```

✅ **Wenn du das siehst:** Push erfolgreich!

---

# Repository klonen

## Von GitHub/GitLab klonen

```bash
git clone git@github.com:USERNAME/REPO-NAME.git
```

**Was passiert:** Repository wird heruntergeladen

**Erwartete Ausgabe:**
```
Cloning into 'REPO-NAME'...
...
done.
```

## In das Verzeichnis wechseln

```bash
cd REPO-NAME
```

---

# GitHub CLI (Alternative - Optional)

## Was ist GitHub CLI?

`gh` ist ein Kommandozeilen-Tool für GitHub-Operationen.

**WICHTIG:**
- ❌ GitHub CLI ist NICHT vorinstalliert
- ✅ Installation ist OPTIONAL (nicht erforderlich)
- Macht GitHub-Operationen einfacher

## Installiere GitHub CLI

### Für Termux:
```bash
pkg install gh
```

### Für Linux/WSL:
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### Für macOS:
```bash
brew install gh
```

## Authentifizierung mit gh

```bash
gh auth login
```

**Was passiert:** Interaktive Anmeldung startet

**Folge den Schritten:**
1. "What account do you want to log into?" → Wähle: `GitHub.com`
2. "What is your preferred protocol?" → Wähle: `SSH`
3. "Upload your SSH public key to GitHub?" → Wähle: `Yes`
4. "Authenticate Git with your GitHub credentials?" → Wähle: `Yes`

## Repository mit gh erstellen

```bash
gh repo create mein-projekt --public --source=. --push
```

**Was passiert:**
- Erstellt Repository "mein-projekt" auf GitHub
- Macht es öffentlich
- Pusht aktuellen Code

---

# Häufige Fehler

## Fehler 1: "Please tell me who you are"

**Vollständige Fehlermeldung:**
```
Please tell me who you are.
Run
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

**Problem:** Git-Konfiguration fehlt

**Lösung:** Siehe Schritt 3 oben

## Fehler 2: "Permission denied (publickey)"

**Problem:** SSH-Key nicht richtig eingerichtet

**Lösung:**
1. Prüfe ob SSH-Key existiert: `ls ~/.ssh/id_ed25519.pub`
2. Wenn nicht: Erstelle einen (Schritt 4)
3. Füge zu GitHub hinzu (Schritt 6)
4. Teste Verbindung (Schritt 7)

## Fehler 3: "fatal: not a git repository"

**Problem:** Du bist nicht in einem Git-Repository

**Lösung:**
```bash
git init
```

Oder wechsle in ein existierendes Repository:
```bash
cd /pfad/zum/repository
```

## Fehler 4: "failed to push some refs"

**Problem:** Remote-Repository hat neuere Änderungen

**Lösung:**
```bash
git pull --rebase origin main
git push origin main
```

---

# Zusammenfassung

## Was standardmäßig VORHANDEN ist:

- ✅ Git (in WSL/Linux/macOS meist vorinstalliert)

## Was du KONFIGURIEREN musst:

1. **Git user.name** → Dein Name
   ```bash
   git config --global user.name "Dein Name"
   ```

2. **Git user.email** → Deine Email
   ```bash
   git config --global user.email "deine@email.de"
   ```

3. **SSH-Key** → Für GitHub/GitLab
   ```bash
   ssh-keygen -t ed25519 -C "deine@email.de"
   ```

4. **SSH-Key zu GitHub/GitLab** → Kopiere Public Key
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
   Dann füge auf GitHub/GitLab hinzu

## Grundlegende Git-Befehle:

```bash
git init                              # Repository erstellen
git add .                             # Dateien hinzufügen
git commit -m "Nachricht"            # Commit erstellen
git remote add origin git@...        # Remote verbinden
git push -u origin main              # Hochladen
git clone git@...                    # Herunterladen
```

## Merke:

- ❌ Git-Konfiguration ist NICHT automatisch
- ❌ SSH-Keys sind NICHT automatisch erstellt
- ✅ Du musst ALLES selbst einrichten (einmalig pro Computer)
- Nach dem Setup funktioniert Git permanent
