# --dsp Flag Implementation Guide

## Overview

This guide provides **permanent** solutions for adding the `--dsp` flag as a shorthand for `--dangerously-skip-permissions` in Claude Code.

After implementation:
- `claude --dsp` will work as a shorthand
- `claude --dangerously-skip-permissions` continues to work
- Both flags do exactly the same thing
- **Survives npm updates permanently**

---

## Choose Your Method

### Method 1: Bash Function (Simplest) ⭐ RECOMMENDED

**Best for:** Personal use, quick setup, bash users

**Pros:**
- ✅ Fastest to implement (2 commands)
- ✅ No separate files needed
- ✅ Works immediately
- ✅ Survives npm updates

**Cons:**
- ❌ Only works in bash
- ❌ Only works in interactive shells
- ❌ Won't work in shell scripts

### Method 2: Wrapper Script (Most Robust)

**Best for:** Production environments, multiple shells, shared systems

**Pros:**
- ✅ Works in all shells (bash, zsh, fish, etc.)
- ✅ Works in non-interactive contexts
- ✅ Works in shell scripts
- ✅ More portable

**Cons:**
- ❌ Slightly more complex setup
- ❌ Requires PATH configuration

---

## Method 1: Bash Function Implementation

### Quick Installation

Add this to your `~/.bashrc`:

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

### Step-by-Step Installation

**Step 1: Open your bash configuration**

```bash
nano ~/.bashrc
```

**Step 2: Scroll to the end and add the function**

Copy and paste the function above at the end of the file.

**Step 3: Save and exit**

- Press `Ctrl + O` to save
- Press `Enter` to confirm
- Press `Ctrl + X` to exit

**Step 4: Reload your shell configuration**

```bash
source ~/.bashrc
```

**Step 5: Test it**

```bash
echo "test" | claude --dsp -p "Say: DSP working!"
```

Expected output: `DSP working!`

### Automatic Installation

```bash
cat >> ~/.bashrc << 'EOF'

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
EOF

source ~/.bashrc
```

### How It Works

1. The bash function intercepts the `claude` command
2. It scans all arguments for `--dsp`
3. Replaces `--dsp` with `--dangerously-skip-permissions`
4. Calls the real `claude` command with modified arguments
5. Uses `command` to avoid infinite recursion

### Verification

```bash
# Check if function exists
type claude
# Should output: "claude is a function"

# Test the flag
echo "test" | claude --dsp -p "what is 2+2?"
# Should output: 4 (or similar response)

# Test original flag still works
echo "test" | claude --dangerously-skip-permissions -p "what is 3+3?"
# Should output: 6 (or similar response)
```

---

## Method 2: Wrapper Script Implementation

### Automated Installation

```bash
# Download and run the installer
bash <(curl -s https://raw.githubusercontent.com/tpdhd/claude-setup/master/install-dsp-flag.sh)

# Or if you have the repo cloned
cd ~/claude-setup
./install-dsp-flag.sh
```

### Manual Installation

**Step 1: Create wrapper directory**

```bash
mkdir -p ~/.local/bin
```

**Step 2: Create wrapper script**

```bash
cat > ~/.local/bin/claude << 'EOF'
#!/bin/bash

# Permanent wrapper script for Claude that adds support for --dsp flag
# This survives npm updates to Claude Code by intercepting calls before the real binary

# Find the real Claude binary (skip our wrapper)
REAL_CLAUDE=""

# Try which -a to find all claude binaries
for claude_path in $(which -a claude 2>/dev/null); do
    # Skip our own wrapper
    if [[ "$claude_path" != "$HOME/.local/bin/claude" ]]; then
        REAL_CLAUDE="$claude_path"
        break
    fi
done

# If not found, try common locations
if [[ -z "$REAL_CLAUDE" ]] || [[ ! -f "$REAL_CLAUDE" ]]; then
    for path in \
        "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "$HOME/.npm-global/bin/claude" \
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/usr/local/bin/claude" \
        "$HOME/.nvm/versions/node/*/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        if [[ -f "$path" ]]; then
            REAL_CLAUDE="$path"
            break
        fi
    done
fi

# Check if we found Claude
if [[ -z "$REAL_CLAUDE" ]] || [[ ! -f "$REAL_CLAUDE" ]]; then
    echo "Error: Cannot find real Claude binary" >&2
    echo "Searched in standard npm global locations" >&2
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

**Step 3: Make script executable**

```bash
chmod +x ~/.local/bin/claude
```

**Step 4: Update PATH**

For Bash:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

For Zsh:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**IMPORTANT:** This line must come AFTER any npm or nvm PATH configurations.

**Step 5: Verify installation**

```bash
# Check which Claude is found first
which claude
# Expected: /home/yourusername/.local/bin/claude

# Test the flag
echo "test" | claude --dsp -p "Say: DSP working!"
```

### How It Works

1. **PATH Priority**: The wrapper is in `~/.local/bin`, which is checked before npm directories
2. **Interception**: When you type `claude`, the shell finds the wrapper first
3. **Argument Processing**: The wrapper replaces `--dsp` with `--dangerously-skip-permissions`
4. **Delegation**: The wrapper calls the real Claude binary
5. **Transparency**: Uses `exec` to replace the wrapper process

---

## Comparison Table

| Feature | Bash Function | Wrapper Script |
|---------|---------------|----------------|
| Setup Time | 30 seconds | 2 minutes |
| Commands Needed | 2 | 4-5 |
| Works in Bash | ✅ Yes | ✅ Yes |
| Works in Zsh | ❌ No | ✅ Yes |
| Works in Scripts | ❌ No | ✅ Yes |
| Works Non-Interactive | ❌ No | ✅ Yes |
| Survives npm updates | ✅ Yes | ✅ Yes |
| Easy to Remove | ✅ Very Easy | ✅ Easy |

---

## Troubleshooting

### Bash Function Issues

**Problem:** "claude: command not found" from inside function

**Solution:** Make sure Claude Code is installed and in PATH:
```bash
which claude
# Should show Claude location (not the function)
```

**Problem:** Function not working after adding to .bashrc

**Solution:** Reload your shell:
```bash
source ~/.bashrc
# Or open a new terminal
```

**Problem:** Changes disappear after reboot

**Solution:** Make sure you added the function to `~/.bashrc` not just typed it in the terminal.

### Wrapper Script Issues

**Problem:** "which claude" still shows npm global path

**Solution:**
1. Check PATH order: `echo $PATH | tr ':' '\n' | head -5`
2. Ensure `~/.local/bin` appears BEFORE npm directories
3. Reload shell: `source ~/.bashrc`

**Problem:** "Cannot find real Claude binary"

**Solution:**
1. Find Claude: `npm list -g @anthropic-ai/claude-code`
2. Edit wrapper at `~/.local/bin/claude`
3. Update `REAL_CLAUDE` variable with correct path

---

## Uninstallation

### Remove Bash Function

1. Open `~/.bashrc`:
   ```bash
   nano ~/.bashrc
   ```

2. Delete the `claude()` function block

3. Save and reload:
   ```bash
   source ~/.bashrc
   ```

### Remove Wrapper Script

```bash
# Remove wrapper
rm ~/.local/bin/claude

# Optionally remove PATH line from shell config
nano ~/.bashrc
# Find and delete the line: export PATH="$HOME/.local/bin:$PATH"

# Reload shell
source ~/.bashrc
```

Verify:
```bash
which claude
# Should show npm global path again

claude --dsp
# Should show error: "unknown option '--dsp'"
```

---

## For AI Assistants

When implementing the `--dsp` flag for users:

1. **Ask about their setup:**
   - Are they using bash or zsh?
   - Do they need it to work in scripts?

2. **Recommend based on needs:**
   - Personal use, bash only → Bash Function Method
   - Production, multiple shells → Wrapper Script Method

3. **Implement carefully:**
   - Always use heredocs with single quotes to prevent variable expansion
   - Test in a new shell after implementation
   - Verify both `--dsp` and `--dangerously-skip-permissions` work

4. **Never suggest:**
   - ❌ Modifying the Claude binary directly (gets reset on updates)
   - ❌ Shell aliases for `--dsp` (doesn't expand the flag)

---

## Summary

- **Bash Function:** Quick, simple, perfect for personal bash use
- **Wrapper Script:** Robust, portable, works everywhere
- Both methods are permanent and survive npm updates
- Choose based on your needs and environment

The `--dsp` flag makes Claude Code easier to use while maintaining the same security considerations as `--dangerously-skip-permissions`.

**Remember:** Only use dangerously-skip-permissions mode in safe, sandboxed environments where Claude can't cause harm.
