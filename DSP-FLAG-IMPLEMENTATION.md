# --dsp Flag Implementation Guide (PERMANENT SOLUTION)

## CRITICAL UNDERSTANDING

This guide provides a **PERMANENT** solution for adding the `--dsp` flag to Claude Code.

**The wrapper script method (recommended):**
- Creates `--dsp` as a permanent shorthand for `--dangerously-skip-permissions`
- Survives ALL npm updates and reinstalls
- Never needs to be reapplied
- Works transparently like a built-in flag

**DO NOT confuse this with:**
- Shell aliases (only work in interactive shells)
- Binary modification (gets reset on npm updates)

---

## What This Does

After implementation:
- `claude --dsp` will work (NEW)
- `claude --dangerously-skip-permissions` will still work (UNCHANGED)
- Both flags do the EXACT same thing
- **Works permanently across all npm updates**

---

## RECOMMENDED: Permanent Wrapper Script Method

This is the **BEST** solution because it:
- ✅ Survives npm updates permanently
- ✅ Never needs reapplication
- ✅ Works in all shells and contexts
- ✅ Easy to maintain and understand
- ✅ Doesn't modify Claude binary

### Prerequisites

1. Claude Code must be installed
2. Basic command line access
3. Bash shell (standard on Linux/macOS/WSL)

### Step 1: Create Wrapper Directory

```bash
mkdir -p ~/.local/bin
```

### Step 2: Create Wrapper Script

Create the file `~/.local/bin/claude` with this content:

```bash
#!/bin/bash

# Permanent wrapper script for Claude that adds support for --dsp flag
# This survives npm updates to Claude Code by intercepting calls before the real binary

# The real Claude binary location (npm global installation)
REAL_CLAUDE="$(readlink -f "$(which -a claude | grep -v "^$HOME/.local/bin" | head -1)" 2>/dev/null)"

# Fallback: Try common npm global locations
if [[ ! -f "$REAL_CLAUDE" ]]; then
    for path in \
        "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "$HOME/.nvm/versions/node/*/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        if [[ -f "$path" ]]; then
            REAL_CLAUDE="$path"
            break
        fi
    done
fi

# Check if we found Claude
if [[ ! -f "$REAL_CLAUDE" ]]; then
    echo "Error: Cannot find real Claude binary" >&2
    echo "Looked in: npm global directories" >&2
    exit 1
fi

# Process arguments to replace --dsp with --dangerously-skip-permissions
args=()
for arg in "$@"; do
    if [[ "$arg" == "--dsp" ]]; then
        args+=("--dangerously-skip-permissions")
    else
        args+=("$arg")
    fi
done

# Call the real Claude with modified arguments
exec "$REAL_CLAUDE" "${args[@]}"
```

**Quick command to create the wrapper:**

```bash
cat > ~/.local/bin/claude << 'EOF'
#!/bin/bash

# Permanent wrapper script for Claude that adds support for --dsp flag
# This survives npm updates to Claude Code by intercepting calls before the real binary

# The real Claude binary location (npm global installation)
REAL_CLAUDE="$(readlink -f "$(which -a claude | grep -v "^$HOME/.local/bin" | head -1)" 2>/dev/null)"

# Fallback: Try common npm global locations
if [[ ! -f "$REAL_CLAUDE" ]]; then
    for path in \
        "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "$HOME/.nvm/versions/node/*/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        if [[ -f "$path" ]]; then
            REAL_CLAUDE="$path"
            break
        fi
    done
fi

# Check if we found Claude
if [[ ! -f "$REAL_CLAUDE" ]]; then
    echo "Error: Cannot find real Claude binary" >&2
    echo "Looked in: npm global directories" >&2
    exit 1
fi

# Process arguments to replace --dsp with --dangerously-skip-permissions
args=()
for arg in "$@"; do
    if [[ "$arg" == "--dsp" ]]; then
        args+=("--dangerously-skip-permissions")
    else
        args+=("$arg")
    fi
done

# Call the real Claude with modified arguments
exec "$REAL_CLAUDE" "${args[@]}"
EOF
```

### Step 3: Make Script Executable

```bash
chmod +x ~/.local/bin/claude
```

### Step 4: Update PATH

Add `~/.local/bin` to your PATH by editing your shell configuration file.

For **Bash** (most common):

```bash
# Add this line to ~/.bashrc (or create it if it doesn't exist)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

For **Zsh**:

```bash
# Add this line to ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

**IMPORTANT:** Make sure this line comes AFTER any npm or nvm PATH configurations in your shell config file.

### Step 5: Reload Shell Configuration

```bash
# For Bash:
source ~/.bashrc

# For Zsh:
source ~/.zshrc

# Or simply open a new terminal
```

### Step 6: Verify Installation

**Check which Claude is being used:**

```bash
which claude
```

**Expected output:**
```
/home/yourusername/.local/bin/claude
```

If you see `/home/yourusername/.npm-global/bin/claude` or similar, your PATH might not be configured correctly. Make sure `~/.local/bin` appears BEFORE npm directories in your PATH.

**Test the --dsp flag:**

```bash
echo "test" | claude --dsp -p "Say: DSP flag is working!"
```

**Expected output:**
```
DSP flag is working!
```

**Test original flag still works:**

```bash
echo "test" | claude --dangerously-skip-permissions -p "Say: Original flag works!"
```

**Expected output:**
```
Original flag works!
```

---

## Complete Installation Script

For quick installation, run this entire script:

```bash
#!/bin/bash

echo "Installing permanent --dsp flag wrapper for Claude..."

# Step 1: Create directory
mkdir -p ~/.local/bin

# Step 2: Create wrapper script
cat > ~/.local/bin/claude << 'EOF'
#!/bin/bash

# Permanent wrapper script for Claude that adds support for --dsp flag
# This survives npm updates to Claude Code by intercepting calls before the real binary

# The real Claude binary location (npm global installation)
REAL_CLAUDE="$(readlink -f "$(which -a claude | grep -v "^$HOME/.local/bin" | head -1)" 2>/dev/null)"

# Fallback: Try common npm global locations
if [[ ! -f "$REAL_CLAUDE" ]]; then
    for path in \
        "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "$HOME/.nvm/versions/node/*/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        if [[ -f "$path" ]]; then
            REAL_CLAUDE="$path"
            break
        fi
    done
fi

# Check if we found Claude
if [[ ! -f "$REAL_CLAUDE" ]]; then
    echo "Error: Cannot find real Claude binary" >&2
    echo "Looked in: npm global directories" >&2
    exit 1
fi

# Process arguments to replace --dsp with --dangerously-skip-permissions
args=()
for arg in "$@"; do
    if [[ "$arg" == "--dsp" ]]; then
        args+=("--dangerously-skip-permissions")
    else
        args+=("$arg")
    fi
done

# Call the real Claude with modified arguments
exec "$REAL_CLAUDE" "${args[@]}"
EOF

# Step 3: Make executable
chmod +x ~/.local/bin/claude
echo "✓ Wrapper script created at ~/.local/bin/claude"

# Step 4: Update PATH in bashrc if needed
if ! grep -q '$HOME/.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "✓ Added ~/.local/bin to PATH in ~/.bashrc"
else
    echo "✓ ~/.local/bin already in PATH"
fi

# Step 5: Test in new shell
echo ""
echo "Installation complete!"
echo ""
echo "To use in current shell, run:"
echo "  source ~/.bashrc"
echo ""
echo "Or open a new terminal."
echo ""
echo "Test with:"
echo '  echo "test" | claude --dsp -p "Say: DSP flag is working!"'
```

---

## How It Works

### Technical Explanation

1. **PATH Priority**: The wrapper is placed in `~/.local/bin`, which is added to PATH before npm global bin
2. **Interception**: When you type `claude`, your shell finds the wrapper first
3. **Argument Processing**: The wrapper scans all arguments and replaces `--dsp` with `--dangerously-skip-permissions`
4. **Delegation**: The wrapper calls the real Claude binary with the modified arguments
5. **Transparency**: The wrapper uses `exec` to replace itself with Claude, making it invisible in the process tree

### Why This Is Permanent

- The wrapper is a separate file, not a modification of Claude
- npm updates only modify the Claude installation directory
- Your `~/.local/bin` directory and shell configuration are never touched by npm
- The wrapper automatically finds the real Claude binary even after updates

---

## Troubleshooting

### Problem: "which claude" still shows npm global path

**Cause:** PATH is not configured correctly or shell hasn't reloaded configuration.

**Solution:**
1. Open a new terminal or run `source ~/.bashrc`
2. Verify PATH order: `echo $PATH | tr ':' '\n' | head -5`
3. Ensure `~/.local/bin` appears BEFORE npm directories
4. If not, check that your `~/.bashrc` has the PATH export line AFTER npm/nvm configurations

### Problem: "Cannot find real Claude binary"

**Cause:** Claude is installed in an unusual location.

**Solution:**
1. Find Claude's actual location: `npm list -g @anthropic-ai/claude-code`
2. Edit the wrapper at `~/.local/bin/claude`
3. Update the `REAL_CLAUDE` variable to point to your Claude location

### Problem: Wrapper not working after npm update

**This should never happen**, but if it does:

1. Verify wrapper still exists: `ls -l ~/.local/bin/claude`
2. Verify it's still executable: `chmod +x ~/.local/bin/claude`
3. Test the real Claude location: The wrapper auto-detects it
4. Check PATH order: `which -a claude` should show wrapper first

### Problem: "--dsp" flag not working

**Cause:** Wrapper is not being called or has a bug.

**Solution:**
1. Test wrapper directly: `~/.local/bin/claude --help`
2. Check which Claude is being used: `which claude`
3. If seeing npm version, check PATH configuration
4. Verify wrapper has correct permissions: `ls -l ~/.local/bin/claude`

---

## Uninstallation

To remove the --dsp flag wrapper:

```bash
# Remove wrapper script
rm ~/.local/bin/claude

# Optionally remove the PATH line from ~/.bashrc
sed -i '/\.local\/bin/d' ~/.bashrc

# Reload shell
source ~/.bashrc
```

Verify:
```bash
which claude
# Should show: /home/yourusername/.npm-global/bin/claude (or similar npm path)

claude --dsp
# Should show error: "unknown option '--dsp'"
```

---

## Important Notes

1. **Permanent Solution**: Unlike binary modification, this NEVER needs reapplication
2. **Update-Safe**: Survives all npm updates, reinstalls, and version changes
3. **Transparent**: Works exactly like a built-in flag
4. **Maintainable**: Easy to modify or remove
5. **No Side Effects**: Doesn't modify Claude installation
6. **Universal**: Works on Linux, macOS, WSL, and any Unix-like system
7. **Shell-Independent**: Works in all contexts, not just interactive shells

---

## For AI Implementation

When implementing this for users:
1. Always create the wrapper in `~/.local/bin` (standard location)
2. Ensure PATH configuration comes AFTER npm/nvm in shell config
3. Use the complete installation script for one-step setup
4. Always verify with `which claude` after installation
5. Test both `--dsp` and `--dangerously-skip-permissions` flags
6. Remind users this survives all npm updates permanently

**Critical:** This is a wrapper approach, not binary modification. It never needs reapplication.

---

# LEGACY METHOD (Not Recommended)

## Binary Modification Method - NON-PERMANENT

**⚠️ WARNING: This method gets reset on every npm update**

The section below describes the old method of modifying the Claude binary directly using `sed`. This approach:
- ❌ Gets overwritten on npm updates
- ❌ Requires reapplication after every Claude update
- ❌ Can break if Claude's internal structure changes
- ❌ Modifies the actual Claude installation

**Use the wrapper script method above instead.**

<details>
<summary>Click to expand legacy binary modification method (not recommended)</summary>

### Legacy Step 1: Find Claude Binary Location

**Command:**
```bash
which claude
```

**Expected Output Examples:**
- Linux/WSL: `/home/username/.npm-global/bin/claude`
- macOS: `/usr/local/bin/claude` or `/Users/username/.npm-global/bin/claude`
- Termux: `/data/data/com.termux/files/usr/bin/claude`

**Important: Check if it's a symlink:**
```bash
ls -l $(which claude)
```

If it shows a symlink (arrow `->` pointing to another file), get the actual file path:
```bash
readlink -f $(which claude)
```

Example: If `which claude` returns `/home/user/.npm-global/bin/claude` but it's a symlink to `../lib/node_modules/@anthropic-ai/claude-code/cli.js`, then the actual path you need is `/home/user/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js`

**Save the actual file path - you need it for all following steps.**

For this guide, we'll use the placeholder: `<CLAUDE_PATH>`

### Legacy Step 2: Create Backup

**CRITICAL: Always backup first!**

**Command:**
```bash
cp <CLAUDE_PATH> <CLAUDE_PATH>.backup
```

**Example:**
```bash
cp /home/username/.npm-global/bin/claude /home/username/.npm-global/bin/claude.backup
```

**Verify backup exists:**
```bash
ls -lh <CLAUDE_PATH>.backup
```

You should see the file listed with size around 10-11 MB.

### Legacy Step 3: Modify Claude Binary

**You need to make THREE changes to the Claude binary file.**

#### Change 1: Add --dsp Option Definition

**What to find:**
```javascript
.option("--dangerously-skip-permissions","Bypass all permission checks. Recommended only for sandboxes with no internet access.",()=>!0)
```

**What to replace it with:**
```javascript
.option("--dangerously-skip-permissions","Bypass all permission checks. Recommended only for sandboxes with no internet access.",()=>!0).option("--dsp","Shorthand for --dangerously-skip-permissions.",()=>!0)
```

**Command to execute:**
```bash
sed -i 's/.option("--dangerously-skip-permissions","Bypass all permission checks. Recommended only for sandboxes with no internet access.",()=>!0)/.option("--dangerously-skip-permissions","Bypass all permission checks. Recommended only for sandboxes with no internet access.",()=>!0).option("--dsp","Shorthand for --dangerously-skip-permissions.",()=>!0)/g' <CLAUDE_PATH>
```

#### Change 2: Add dsp to Parameter Destructuring

**What to find:**
```javascript
let{debug:D=!1,debugToStderr:W=!1,dangerouslySkipPermissions:K,allowDangerouslySkipPermissions:V=!1
```

**What to replace it with:**
```javascript
let{debug:D=!1,debugToStderr:W=!1,dangerouslySkipPermissions:K,dsp:dspFlag,allowDangerouslySkipPermissions:V=!1
```

**Command to execute:**
```bash
sed -i 's/let{debug:D=!1,debugToStderr:W=!1,dangerouslySkipPermissions:K,allowDangerouslySkipPermissions:V=!1/let{debug:D=!1,debugToStderr:W=!1,dangerouslySkipPermissions:K,dsp:dspFlag,allowDangerouslySkipPermissions:V=!1/g' <CLAUDE_PATH>
```

#### Change 3: Combine Both Flags

**What to find:**
```javascript
}=I,x=I.agents,m=I.agent;
```

**What to replace it with:**
```javascript
}=I;K=K||dspFlag;let x=I.agents,m=I.agent;
```

**Command to execute:**
```bash
sed -i 's/}=I,x=I.agents,m=I.agent;/}=I;K=K||dspFlag;let x=I.agents,m=I.agent;/g' <CLAUDE_PATH>
```

### Legacy Step 4: Verify Changes

#### Verification 1: Check Help Output

**Command:**
```bash
claude --help | grep -A 1 "dsp"
```

**Expected Output:**
```
  --dsp                                             Shorthand for --dangerously-skip-permissions.
```

If you see this, the flag was added successfully.

#### Verification 2: Test --dsp Flag

**Command:**
```bash
echo "test" | claude --dsp -p "what is 2+2?"
```

**Expected Output:**
```
2 + 2 = 4
```

If this works, the flag is functioning correctly.

#### Verification 3: Test Original Flag Still Works

**Command:**
```bash
echo "test" | claude --dangerously-skip-permissions -p "what is 3+3?"
```

**Expected Output:**
```
3 + 3 = 6
```

Both flags should work identically.

### Complete Legacy Implementation Script

**For quick implementation, run all commands together:**

```bash
# Step 1: Find Claude location (follow symlinks)
CLAUDE_PATH=$(readlink -f $(which claude) 2>/dev/null || which claude)
echo "Claude found at: $CLAUDE_PATH"

# Step 2: Create backup
cp "$CLAUDE_PATH" "$CLAUDE_PATH.backup"
echo "Backup created at: $CLAUDE_PATH.backup"

# Step 3: Apply all three changes
sed -i 's/.option("--dangerously-skip-permissions","Bypass all permission checks. Recommended only for sandboxes with no internet access.",()=>!0)/.option("--dangerously-skip-permissions","Bypass all permission checks. Recommended only for sandboxes with no internet access.",()=>!0).option("--dsp","Shorthand for --dangerously-skip-permissions.",()=>!0)/g' "$CLAUDE_PATH"

sed -i 's/let{debug:D=!1,debugToStderr:W=!1,dangerouslySkipPermissions:K,allowDangerouslySkipPermissions:V=!1/let{debug:D=!1,debugToStderr:W=!1,dangerouslySkipPermissions:K,dsp:dspFlag,allowDangerouslySkipPermissions:V=!1/g' "$CLAUDE_PATH"

sed -i 's/}=I,x=I.agents,m=I.agent;/}=I;K=K||dspFlag;let x=I.agents,m=I.agent;/g' "$CLAUDE_PATH"

# Step 4: Verify
echo "Verifying changes..."
claude --help | grep -E "(--dsp|--dangerously-skip-permissions)" | grep -v "allow-dangerously"
echo ""
echo "Testing --dsp flag:"
echo "test" | claude --dsp -p "what is 1+1?"

echo ""
echo "⚠️  WARNING: These changes will be lost on next npm update!"
echo "⚠️  Use the wrapper script method instead for permanent solution."
```

### Restore Original Claude (Legacy)

If something goes wrong, restore from backup:

```bash
CLAUDE_PATH=$(which claude)
cp "$CLAUDE_PATH.backup" "$CLAUDE_PATH"
```

Verify:
```bash
claude --help | grep -A 1 "dsp"
```

Should show nothing (flag removed).

</details>

---

**Use the wrapper script method above for a permanent, update-safe solution!**
