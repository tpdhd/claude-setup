# --dsp Flag: Permanent Solution for WSL2/Windows

## The Problem: Why the DSP Flag Keeps "Resetting"

The `--dsp` flag (shorthand for `--dangerously-skip-permissions`) is NOT a built-in Claude Code feature. It must be implemented manually. If you're experiencing it "working at first, then stopping after a short while," here's why:

### Root Causes

1. **Bash Function Limitations** (Current Setup)
   - Only works in **interactive bash shells**
   - Doesn't work when Claude is launched from:
     - Windows GUI applications
     - Shell scripts (non-interactive context)
     - Windows Terminal in certain modes
     - Cron jobs, systemd services, or other automated contexts

2. **WSL2-Specific Issues**
   - Login shells vs non-login shells load different configuration files
   - Windows Terminal may not always source `~/.bashrc`
   - Some launch contexts bypass shell configuration entirely

3. **Hardcoded Paths**
   - If your bash function uses a hardcoded path like `/home/user/.npm-global/bin/claude`, it will break if npm reinstalls Claude elsewhere

4. **The Illusion of "Deleting Itself"**
   - The function never gets deleted from `~/.bashrc`
   - It just doesn't load in certain contexts
   - This makes it seem like it "resets" or "disappears"

---

## The Solution: Wrapper Script Method (RECOMMENDED)

The wrapper script method is more robust because:
- ✅ Works in **ALL contexts** (interactive, non-interactive, GUI, scripts)
- ✅ Works in **ALL shells** (bash, zsh, fish, etc.)
- ✅ Doesn't depend on shell configuration files
- ✅ Survives npm updates permanently
- ✅ Will be found first in PATH regardless of how Claude is launched

---

## Implementation Steps

### Step 1: Remove Old Bash Function (Optional Cleanup)

Edit your `~/.bashrc`:
```bash
nano ~/.bashrc
```

Find and remove these lines (usually near the end):
```bash
# Claude wrapper function to expand --dsp to --dangerously-skip-permissions
claude() {
    local args=()
    for arg in "$@"; do
        if [ "$arg" = "--dsp" ]; then
            args+=("--dangerously-skip-permissions")
        else
            args+=("$arg")
        fi
    done
    command claude "${args[@]}"  # or command /path/to/claude
}
```

Save and exit (Ctrl+O, Enter, Ctrl+X).

### Step 2: Run the Automated Installer

```bash
cd ~/claude-setup
./install-dsp-flag.sh
```

Or from anywhere:
```bash
bash <(curl -s https://raw.githubusercontent.com/tpdhd/claude-setup/master/install-dsp-flag.sh)
```

### Step 3: Open a NEW Terminal

**IMPORTANT:** The wrapper won't work in your current terminal session until you:
- Run `source ~/.bashrc` (for current session only), OR
- Close and open a new terminal window (recommended)

### Step 4: Verify It Works

```bash
# Check that wrapper is found first
which claude
# Expected output: /home/yourusername/.local/bin/claude

# Test the --dsp flag
echo "test" | claude --dsp -p "Say: Working!"
# Expected output: "Working!"

# Or run the verification script
cd ~/claude-setup
./verify-dsp.sh
```

---

## How the Wrapper Script Works

### Architecture

```
User types: claude --dsp

    ↓

Shell checks PATH (left to right):
  ~/.local/bin/claude  ← Found first! (our wrapper)
  ~/.npm-global/bin/claude  ← Never reached

    ↓

Wrapper script:
  1. Finds the real Claude binary (npm installation)
  2. Replaces --dsp with --dangerously-skip-permissions
  3. Calls real Claude with modified arguments

    ↓

Real Claude runs with --dangerously-skip-permissions
```

### Why It's Permanent

1. **PATH Priority:** `~/.local/bin` is added to the START of your PATH in `~/.bashrc`
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

2. **Survives npm Updates:** Even if npm updates or reinstalls Claude, the wrapper script:
   - Remains in `~/.local/bin/claude`
   - Uses dynamic detection to find the real Claude binary
   - Doesn't hardcode paths

3. **Works in All Contexts:** Unlike bash functions, wrapper scripts:
   - Are actual files on disk (not just shell functions)
   - Are found by the shell's PATH mechanism
   - Work regardless of interactive vs non-interactive shells

---

## Troubleshooting

### Issue 1: "which claude" shows npm path, not wrapper

**Cause:** PATH order incorrect or shell config not reloaded

**Fix:**
```bash
# Check PATH order
echo "$PATH" | tr ':' '\n' | head -5
# ~/.local/bin should appear BEFORE npm directories

# Reload shell
source ~/.bashrc

# Or open a new terminal
```

### Issue 2: "Cannot find real Claude binary"

**Cause:** Claude installed in non-standard location

**Fix:**
```bash
# Find Claude
npm list -g @anthropic-ai/claude-code

# Edit wrapper to add your path
nano ~/.local/bin/claude
# Add your path to the fallback locations around line 47-56
```

### Issue 3: --dsp still not working after installation

**Cause:** Old terminal session or cached PATH

**Fix:**
```bash
# Close ALL terminal windows
# Open a NEW terminal
# Test again
which claude
echo "test" | claude --dsp -p "Say: Test"
```

### Issue 4: Works in terminal but not from GUI apps

**Good news:** This means the wrapper is working correctly!

**Note:** The wrapper script method works even when launched from GUI applications because:
- GUI apps use the system PATH
- `~/.local/bin` is in the PATH
- The wrapper is found before the real Claude

If it's not working, check that `~/.local/bin` is in your PATH:
```bash
# Add to ~/.profile for GUI apps (WSL2)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

---

## WSL2-Specific Notes

### Login Shells vs Interactive Shells

- **Interactive non-login shells** (most terminal sessions): Source `~/.bashrc`
- **Login shells** (some GUI launches): Source `~/.profile` or `~/.bash_profile`

**Solution:** The install script adds PATH to `~/.bashrc`, which handles most cases. For GUI applications, you may also need to add to `~/.profile`:

```bash
# Add to ~/.profile for login shells
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

### Windows Terminal Configuration

If you're using Windows Terminal, ensure your WSL profile uses a login shell:
1. Open Windows Terminal Settings (Ctrl+,)
2. Find your WSL profile
3. Check "Command line" setting
4. Should be: `wsl.exe ~` or `bash -l` (login shell)

---

## Manual Installation (If Automated Script Fails)

### Create Wrapper Script

```bash
# 1. Create directory
mkdir -p ~/.local/bin

# 2. Create wrapper script
cat > ~/.local/bin/claude << 'EOF'
#!/bin/bash

# Find the real Claude binary
REAL_CLAUDE=""
for claude_path in $(which -a claude 2>/dev/null); do
    if [[ "$claude_path" != "$HOME/.local/bin/claude" ]]; then
        REAL_CLAUDE="$claude_path"
        break
    fi
done

# Fallback to common locations
if [[ -z "$REAL_CLAUDE" ]] || [[ ! -f "$REAL_CLAUDE" ]]; then
    for path in \
        "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "$HOME/.npm-global/bin/claude" \
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/usr/local/bin/claude"; do
        if [[ -f "$path" ]]; then
            REAL_CLAUDE="$path"
            break
        fi
    done
fi

# Error if not found
if [[ -z "$REAL_CLAUDE" ]] || [[ ! -f "$REAL_CLAUDE" ]]; then
    echo "Error: Cannot find real Claude binary" >&2
    exit 1
fi

# Replace --dsp with --dangerously-skip-permissions
args=()
for arg in "$@"; do
    if [[ "$arg" == "--dsp" ]]; then
        args+=("--dangerously-skip-permissions")
    else
        args+=("$arg")
    fi
done

# Execute real Claude
exec "$REAL_CLAUDE" "${args[@]}"
EOF

# 3. Make executable
chmod +x ~/.local/bin/claude

# 4. Add to PATH (bash)
if ! grep -q '$HOME/.local/bin' ~/.bashrc 2>/dev/null; then
    echo '' >> ~/.bashrc
    echo '# Add ~/.local/bin to PATH (for Claude --dsp wrapper)' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# 5. Reload shell
source ~/.bashrc

# 6. Verify
which claude
echo "test" | claude --dsp -p "Say: Success!"
```

---

## Verification Script

Run the verification script to check your installation:

```bash
cd ~/claude-setup
./verify-dsp.sh
```

Expected output:
```
=========================================
DSP Flag Verification
=========================================

✓ Wrapper script exists at ~/.local/bin/claude
✓ Wrapper script is executable
✓ Wrapper is found first in PATH: /home/username/.local/bin/claude

Testing --dsp flag...
✓ --dsp flag is working!

Testing original --dangerously-skip-permissions flag...
✓ Original flag still works!

=========================================
All checks passed!
=========================================

You can now use: claude --dsp
This will persist across all npm updates.
```

---

## Summary

### Why Bash Functions Fail in WSL2

| Context | Bash Function Works? | Wrapper Script Works? |
|---------|---------------------|----------------------|
| Interactive bash terminal | ✅ Yes | ✅ Yes |
| Non-interactive bash | ❌ No | ✅ Yes |
| Shell scripts | ❌ No | ✅ Yes |
| Windows GUI launch | ❌ No | ✅ Yes |
| Cron jobs | ❌ No | ✅ Yes |
| Login shells | ❌ Maybe | ✅ Yes |

### Why the Wrapper Script is Superior

1. **Context-Independent:** Works regardless of how Claude is launched
2. **Shell-Independent:** Works in bash, zsh, fish, etc.
3. **Dynamic Path Detection:** Finds Claude automatically, no hardcoded paths
4. **PATH-Based:** Uses standard Unix PATH mechanism
5. **Permanent:** Survives npm updates, system reboots, WSL restarts

---

## Uninstallation

To remove the wrapper script:

```bash
# Remove wrapper
rm ~/.local/bin/claude

# Remove PATH line from ~/.bashrc (optional)
nano ~/.bashrc
# Find and delete: export PATH="$HOME/.local/bin:$PATH"

# Reload shell
source ~/.bashrc
```

Verify removal:
```bash
which claude
# Should show npm global path again

claude --dsp
# Should show error: "unknown option '--dsp'"
```

---

## Additional Resources

- **Repository:** https://github.com/tpdhd/claude-setup
- **Automated Installer:** `./install-dsp-flag.sh`
- **Verification Script:** `./verify-dsp.sh`
- **Sound Notifications:** See `SOUND-SETUP.md`
- **General Setup:** See `INSTALL.md`, `GIT_SETUP.md`, `COMMANDS.md`

---

**Remember:** Only use `--dangerously-skip-permissions` mode in safe, sandboxed environments where Claude can't cause harm.
