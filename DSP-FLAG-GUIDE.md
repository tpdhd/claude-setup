# Complete --dsp Flag Guide for Claude Code

## What is the --dsp Flag?

The `--dsp` flag is a **custom shorthand** for `--dangerously-skip-permissions` in Claude Code. It's NOT built-in - you must implement it yourself.

After implementation:
- `claude --dsp` works as shorthand
- `claude --dangerously-skip-permissions` continues to work
- Both flags do exactly the same thing
- Survives npm updates permanently

**Security Note:** Only use in safe, sandboxed environments where Claude can't cause harm.

---

## Quick Installation (One-Command Method)

### Automated Installation

Run this single command to install the --dsp flag:

```bash
bash << 'INSTALLER_EOF'
#!/bin/bash
set -e

echo "========================================="
echo "Claude Code --dsp Flag Installer"
echo "========================================="
echo ""

# Check if Claude is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude Code is not installed or not in PATH"
    echo "   Please install Claude Code first: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

echo "✓ Claude Code found at: $(which claude)"
echo ""

# Create directory
echo "[1/4] Creating ~/.local/bin directory..."
mkdir -p ~/.local/bin
echo "✓ Directory created"
echo ""

# Create wrapper script
echo "[2/4] Creating wrapper script..."
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

exec "$REAL_CLAUDE" "${args[@]}"
EOF

chmod +x ~/.local/bin/claude
echo "✓ Wrapper script created"
echo ""

# Update PATH
echo "[3/4] Updating PATH configuration..."
SHELL_CONFIG=""
if [[ -f ~/.bashrc ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [[ -f ~/.zshrc ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi

if [[ -n "$SHELL_CONFIG" ]]; then
    if ! grep -q '$HOME/.local/bin' "$SHELL_CONFIG" 2>/dev/null && ! grep -q '~/.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Add ~/.local/bin to PATH (for Claude --dsp wrapper)" >> "$SHELL_CONFIG"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        echo "✓ Added ~/.local/bin to PATH in $SHELL_CONFIG"
    else
        echo "✓ ~/.local/bin already in PATH"
    fi
fi
echo ""

# Test installation
echo "[4/4] Installation complete!"
echo ""
echo "========================================="
echo "IMPORTANT: Open a NEW terminal or run:"
echo "  source ~/.bashrc"
echo ""
echo "Then test with:"
echo '  which claude    # Should show: ~/.local/bin/claude'
echo '  echo "test" | claude --dsp -p "Say: Working!"'
echo "========================================="
INSTALLER_EOF
```

Then **open a NEW terminal** and test:
```bash
which claude  # Should show: ~/.local/bin/claude
echo "test" | claude --dsp -p "Say: Working!"
```

### Manual Verification

After installation, verify with these checks:

```bash
# Check wrapper exists
[[ -f ~/.local/bin/claude ]] && echo "✓ Wrapper exists" || echo "✗ Wrapper missing"

# Check wrapper is executable
[[ -x ~/.local/bin/claude ]] && echo "✓ Wrapper executable" || echo "✗ Not executable"

# Check which Claude is found
FOUND_CLAUDE=$(which claude)
if [[ "$FOUND_CLAUDE" == "$HOME/.local/bin/claude" ]]; then
    echo "✓ Wrapper found first in PATH"
else
    echo "⚠ Wrapper not found first. Found: $FOUND_CLAUDE"
    echo "  Run: source ~/.bashrc"
fi

# Test --dsp flag
echo "test" | timeout 5 claude --dsp -p "Say: OK" 2>&1 | grep -q "OK" && echo "✓ --dsp working!" || echo "✗ --dsp not working"
```

---

## Why the Flag "Keeps Resetting" (Common Problem)

If you're experiencing the `--dsp` flag working at first, then stopping after a while, here's why:

### Root Cause: Bash Function Limitations

Many guides recommend adding a bash function to `~/.bashrc`. This **only works in interactive bash shells** and fails in:
- Windows GUI application launches
- Non-interactive shells
- Shell scripts
- Cron jobs
- Certain WSL2 contexts

This creates the illusion of the flag "deleting itself" or "resetting" - but it's not deleting, it's just not loading in those contexts.

### The Solution: Wrapper Script Method

The wrapper script method (used by our installer) works in **ALL contexts** because:
- It's a real file at `~/.local/bin/claude`, not a shell function
- Found via PATH mechanism, not shell configuration
- Works regardless of interactive/non-interactive shells
- Doesn't depend on `.bashrc` loading

| Context | Bash Function | Wrapper Script |
|---------|---------------|----------------|
| Interactive terminal | ✅ Yes | ✅ Yes |
| Windows GUI launch | ❌ No | ✅ Yes |
| Shell scripts | ❌ No | ✅ Yes |
| Non-interactive shells | ❌ No | ✅ Yes |
| Cron jobs | ❌ No | ✅ Yes |

---

## Manual Installation Methods

### Method 1: Wrapper Script (Most Robust) ⭐ RECOMMENDED

**Best for:** All use cases, especially WSL2/Windows, production, scripts

#### Step 1: Create Directory
```bash
mkdir -p ~/.local/bin
```

#### Step 2: Create Wrapper Script
```bash
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
```

#### Step 3: Make Executable
```bash
chmod +x ~/.local/bin/claude
```

#### Step 4: Update PATH

**For Bash:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**For Zsh:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**IMPORTANT:** This PATH line must come AFTER any npm or nvm PATH configurations.

#### Step 5: Verify
```bash
# Check wrapper is found first
which claude
# Expected: /home/yourusername/.local/bin/claude

# Test it works
echo "test" | claude --dsp -p "Say: Working!"
```

### Method 2: Bash Function (Simple, Limited)

**Best for:** Personal bash use only, quick temporary setup

**Limitations:**
- Only works in interactive bash shells
- Doesn't work in scripts, GUI launches, or non-interactive contexts
- May appear to "reset" in WSL2/Windows environments

#### Add to ~/.bashrc:
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
    command claude "${args[@]}"
}
```

#### Reload:
```bash
source ~/.bashrc
```

#### Test:
```bash
type claude  # Should show: "claude is a function"
echo "test" | claude --dsp -p "Say: Working!"
```

---

## How It Works

### Wrapper Script Architecture

```
User types: claude --dsp
    ↓
Shell checks PATH (left to right):
  ~/.local/bin/claude ← Found first! (our wrapper)
  ~/.npm-global/bin/claude ← Never reached
    ↓
Wrapper script:
  1. Finds the real Claude binary
  2. Replaces --dsp with --dangerously-skip-permissions
  3. Calls real Claude with modified arguments
    ↓
Real Claude runs with full flag
```

### Why It's Permanent

1. **PATH Priority:** `~/.local/bin` is at the START of PATH
2. **Survives Updates:** Wrapper is separate from npm package
3. **Dynamic Detection:** Finds real Claude automatically
4. **Context-Independent:** Works everywhere, not just interactive shells

---

## Troubleshooting

### Issue: "which claude" shows npm path, not wrapper

**Cause:** PATH order incorrect or shell config not reloaded

**Fix:**
```bash
# Check PATH order
echo "$PATH" | tr ':' '\n' | head -5
# ~/.local/bin should appear BEFORE npm directories

# Reload shell
source ~/.bashrc
# Or open new terminal
```

### Issue: "Cannot find real Claude binary"

**Cause:** Claude installed in non-standard location

**Fix:**
```bash
# Find Claude
npm list -g @anthropic-ai/claude-code

# Edit wrapper to add your path
nano ~/.local/bin/claude
# Add your path to the fallback locations
```

### Issue: --dsp works in terminal but not GUI apps

**Fix for WSL2:**
```bash
# Add to ~/.profile for login shells
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

### Issue: Changes disappear after reboot (bash function only)

**Cause:** Function not saved to ~/.bashrc

**Fix:** Make sure you added the function to `~/.bashrc` file, not just typed it in terminal.

### Issue: Function not found after adding to .bashrc

**Fix:**
```bash
source ~/.bashrc
# Or open new terminal
```

---

## Platform-Specific Notes

### WSL2 (Windows Subsystem for Linux)

**Recommended:** Use wrapper script method (not bash function)

**Why:** WSL2 has multiple shell contexts:
- Interactive non-login shells (most terminals) → source `~/.bashrc`
- Login shells (some GUI launches) → source `~/.profile` or `~/.bash_profile`

Bash functions only work in interactive shells. The wrapper script works everywhere.

**Additional Setup for GUI Apps:**
```bash
# Add to ~/.profile for login shells
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
```

### macOS

**Default shell:** zsh (Catalina+)

**Wrapper Script Method:**
- Add PATH to `~/.zshrc` instead of `~/.bashrc`
- Otherwise same as Linux

**Bash Function Method:**
- For zsh, add function to `~/.zshrc` with zsh syntax
- Or use wrapper script for better compatibility

### Linux

**Recommended:** Wrapper script for production, bash function for personal use

Most distros use bash by default. Check with: `echo $SHELL`

---

## Uninstallation

### Remove Wrapper Script
```bash
# Remove wrapper
rm ~/.local/bin/claude

# Optionally remove PATH line from shell config
nano ~/.bashrc  # or ~/.zshrc
# Delete: export PATH="$HOME/.local/bin:$PATH"

# Reload
source ~/.bashrc
```

### Remove Bash Function
```bash
# Edit shell config
nano ~/.bashrc

# Delete the claude() function block

# Reload
source ~/.bashrc
```

### Verify Removal
```bash
which claude
# Should show npm global path

claude --dsp
# Should show error: "unknown option '--dsp'"
```

---

## Usage Examples

### Basic Usage
```bash
# Interactive mode with --dsp
claude --dsp

# Non-interactive mode
echo "code here" | claude --dsp -p "review this code"

# Save output
claude --dsp -p "create hello world script" > script.sh
```

### Common Workflows
```bash
# Code review
cat myfile.py | claude --dsp -p "find bugs in this code"

# Process multiple files
for file in *.txt; do
    claude --dsp -p "summarize $file" < "$file" > "${file%.txt}_summary.txt"
done

# Generate commit message
git diff | claude --dsp -p "write a concise commit message"
```

---

## Summary

### Quick Decision Guide

**Choose Wrapper Script if:**
- Using WSL2/Windows
- Need it to work from GUI applications
- Need it in shell scripts
- Want it to work 100% reliably everywhere

**Choose Bash Function if:**
- Only using interactive bash terminal
- Want quickest setup (30 seconds)
- Don't need it in scripts or non-interactive contexts

### Installation Summary

**Fastest:** Run the one-command installer (see Quick Installation section above)

**Most Reliable:** Wrapper script method (what the installer uses)

**Simplest:** Bash function (but has limitations in WSL2/Windows)

---

## Additional Resources

- **Repository:** https://github.com/tpdhd/claude-setup
- **Installation Script:** See automated installation section above
- **Sound Notifications:** See [SOUND-NOTIFICATION-HOOKS-GUIDE.md](./SOUND-NOTIFICATION-HOOKS-GUIDE.md)
- **General Setup:** See [CLAUDE-CODE-INSTALLATION-GUIDE.md](./CLAUDE-CODE-INSTALLATION-GUIDE.md), [GIT-CONFIGURATION-GUIDE.md](./GIT-CONFIGURATION-GUIDE.md)

---

**Remember:** Only use `--dangerously-skip-permissions` mode in safe, sandboxed environments where Claude can't cause harm.
