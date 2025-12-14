# Claude Code Befehle - Einfache Anleitung

## Problem: Der lange Befehl

Claude Code hat einen sehr langen Befehl:
```bash
claude --dangerously-skip-permissions
```

Dieser Befehl ist lang und nervt beim Tippen.

## Lösung: Einen kurzen Alias erstellen

Wir erstellen einen **Alias** (Abkürzung), damit wir stattdessen nur schreiben:
```bash
dsp
```

## WICHTIG ZU VERSTEHEN:

1. **Was FUNKTIONIERT ohne Setup:**
   ```bash
   claude --dangerously-skip-permissions
   ```
   ✅ Dieser Befehl funktioniert SOFORT nach Claude Installation

2. **Was NICHT FUNKTIONIERT ohne Setup:**
   ```bash
   claude --dsp
   dsp
   c
   ```
   ❌ Diese Befehle funktionieren NICHT automatisch
   ❌ Du MUSST sie erst erstellen (siehe unten)

## Was macht der Befehl?

```bash
claude --dangerously-skip-permissions
```

Dieser Befehl startet Claude Code und:
- Überspringt ALLE Berechtigungsfragen
- Claude darf ALLES machen ohne zu fragen
- ⚠️ Nur in sicheren Projekten verwenden!

---

# Schritt-für-Schritt: Alias erstellen

## Für WSL (Windows Subsystem for Linux)

### Schritt 1: Prüfe deine Shell

```bash
echo $SHELL
```

**Erwartete Ausgabe:**
- `/bin/bash` → Du hast Bash (Standard)
- `/bin/zsh` → Du hast Zsh

**Für diese Anleitung:** Wir nehmen an, du hast **Bash**.

### Schritt 2: Öffne die Konfigurationsdatei

```bash
nano ~/.bash_aliases
```

**Was passiert:** Ein Text-Editor öffnet sich.

### Schritt 3: Füge diese EXAKTE Zeile ein

Kopiere und füge diese Zeile ein:

```bash
alias dsp='claude --dangerously-skip-permissions'
```

**Erklärung:**
- `alias` = Erstelle eine Abkürzung
- `dsp` = Der neue kurze Befehl
- `'claude --dangerously-skip-permissions'` = Der echte lange Befehl

### Schritt 4: Speichere die Datei

1. Drücke `Ctrl + O` (Speichern)
2. Drücke `Enter` (Bestätigen)
3. Drücke `Ctrl + X` (Schließen)

### Schritt 5: Aktiviere den Alias

```bash
source ~/.bashrc
```

**Was passiert:** Deine Shell lädt die neuen Einstellungen.

### Schritt 6: Teste den Alias

```bash
dsp
```

**Erwartete Ausgabe:** Claude Code startet im dangerously-skip-permissions Modus.

### Schritt 7: Verifiziere (Optional)

```bash
type dsp
```

**Erwartete Ausgabe:**
```
dsp is aliased to `claude --dangerously-skip-permissions'
```

✅ **Wenn du das siehst:** Der Alias funktioniert!
❌ **Wenn Fehler:** Wiederhole Schritt 2-5

---

## Für Linux

### Schritt 1: Öffne die Konfigurationsdatei

```bash
nano ~/.bashrc
```

### Schritt 2: Gehe ans Ende der Datei

1. Drücke `Ctrl + End` oder scrolle nach unten
2. Füge diese Zeile ein:

```bash
alias dsp='claude --dangerously-skip-permissions'
```

### Schritt 3: Speichere und schließe

1. Drücke `Ctrl + O`, dann `Enter`
2. Drücke `Ctrl + X`

### Schritt 4: Aktiviere

```bash
source ~/.bashrc
```

### Schritt 5: Teste

```bash
dsp
```

---

## Für Termux (Android)

**EXAKTE BEFEHLE - Kopiere sie nacheinander:**

```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.bashrc
```

```bash
source ~/.bashrc
```

```bash
dsp
```

**Was passiert:**
1. Befehl 1: Schreibt den Alias in die Konfigurationsdatei
2. Befehl 2: Lädt die Konfiguration neu
3. Befehl 3: Testet den Alias

---

## Für macOS

### Wenn du Bash hast:

```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.bash_profile
source ~/.bash_profile
dsp
```

### Wenn du Zsh hast (Standard ab macOS Catalina):

```bash
echo "alias dsp='claude --dangerously-skip-permissions'" >> ~/.zshrc
source ~/.zshrc
dsp
```

---

# Zusammenfassung

## VORHER (ohne Alias):

Du musst jedes Mal tippen:
```bash
claude --dangerously-skip-permissions
```

## NACHHER (mit Alias):

Du tippst nur:
```bash
dsp
```

## Beide Befehle machen EXAKT das Gleiche!

Der Alias `dsp` ist nur eine **Abkürzung** für den langen Befehl.

---

# Häufige Fehler

## Fehler 1: "dsp: command not found"

**Problem:** Der Alias wurde nicht richtig erstellt.

**Lösung:**
```bash
type dsp
```

Wenn Fehler kommt: Wiederhole die Schritte 1-5 oben.

## Fehler 2: "claude: command not found"

**Problem:** Claude Code ist nicht installiert.

**Lösung:** Siehe INSTALL.md in diesem Repository.

## Fehler 3: Alias funktioniert nur im aktuellen Terminal

**Problem:** Du hast `source ~/.bashrc` vergessen.

**Lösung:**
```bash
source ~/.bashrc
```

Oder: Schließe das Terminal und öffne ein neues.

---

# Weitere Aliase (Optional)

Du kannst mehrere Aliase erstellen:

```bash
alias dsp='claude --dangerously-skip-permissions'
alias c='claude --dangerously-skip-permissions'
alias cdsp='claude --dangerously-skip-permissions'
```

Dann funktionieren alle drei:
```bash
dsp        # Funktioniert
c          # Funktioniert
cdsp       # Funktioniert
```

Alle drei starten Claude im dangerously-skip-permissions Modus.

---

# Was du dir merken musst

1. `claude --dangerously-skip-permissions` = Der ECHTE Befehl (immer verfügbar)
2. `dsp` = Eine ABKÜRZUNG, die DU erstellen musst
3. Der Alias ist nur in **deinem System** aktiv
4. Andere Computer brauchen eigene Alias-Einrichtung
5. Der Alias ist permanent (bleibt nach Neustart)
