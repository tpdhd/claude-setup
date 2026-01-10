# AI Implementation Guide: Permanent --dsp Flag for Claude Code

This guide is written for AI assistants who need to implement the permanent `--dsp` flag for Claude Code. Follow these steps exactly.

---

## Problem Statement

**User Request:** "I want a `--dsp` flag for Claude Code that works like `--dangerously-skip-permissions` and persists across npm updates."

**Previous Failed Approach:** Modifying the Claude binary directly with `sed` commands. This gets overwritten on every `npm update -g @anthropic-ai/claude-code`.

**Correct Solution:** Create a wrapper script that intercepts calls to Claude BEFORE they reach the real binary.

---

## Solution Architecture

### High-Level Approach

1. Create a bash wrapper script at `~/.local/bin/claude`
2. Configure PATH so `~/.local/bin` comes BEFORE npm global directories
3. The wrapper intercepts `--dsp` and converts it to `--dangerously-skip-permissions`
4. The wrapper then calls the real Claude binary
5. npm updates never touch `~/.local/bin`, so the wrapper persists permanently

### Why This Works

- **PATH Priority**: Shell searches directories in PATH order, left to right
- **Separate Location**: The wrapper lives outside npm's control
- **Transparent Operation**: Uses `exec` to replace the wrapper process with Claude
- **Auto-Detection**: Wrapper finds real Claude even after updates
- **No Modification**: Never touches the actual Claude installation

---

## Implementation Steps for AI

### Step 1: Verify Prerequisites

```bash
# Check if Claude is installed
if ! command -v claude &> /dev/null; then
    echo "Error: Claude Code not installed"
    exit 1
fi

# Verify bash is available
if ! command -v bash &> /dev/null; then
    echo "Error: Bash not found"
    exit 1
fi
```

### Step 2: Create Wrapper Directory

```bash
mkdir -p ~/.local/bin
```

**Why:** `~/.local/bin` is a standard Unix location for user-specific binaries.

### Step 3: Create Wrapper Script

**CRITICAL:** Use a heredoc to avoid quoting issues. Write this EXACT content:

```bash
cat > ~/.local/bin/claude << 'WRAPPER_EOF'
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
WRAPPER_EOF
```

**Key Points:**
- Use `'WRAPPER_EOF'` (with quotes) to prevent variable expansion in heredoc
- The wrapper uses `which -a` to find all Claude binaries and skips itself
- Falls back to hardcoded common locations if `which -a` fails
- Uses `exec` to replace wrapper process (cleaner, more transparent)

### Step 4: Make Wrapper Executable

```bash
chmod +x ~/.local/bin/claude
```

### Step 5: Update PATH Configuration

**Detect the shell configuration file:**

```bash
SHELL_CONFIG=""
if [[ -f ~/.bashrc ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [[ -f ~/.zshrc ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
fi
```

**Add PATH configuration (if not already present):**

```bash
if [[ -n "$SHELL_CONFIG" ]]; then
    # Check if .local/bin is already in PATH config
    if ! grep -q '$HOME/.local/bin' "$SHELL_CONFIG" 2>/dev/null && \
       ! grep -q '~/.local/bin' "$SHELL_CONFIG" 2>/dev/null; then

        # Add to shell config AFTER npm/nvm lines
        echo "" >> "$SHELL_CONFIG"
        echo "# Add ~/.local/bin to PATH (for Claude --dsp wrapper)" >> "$SHELL_CONFIG"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
    fi
fi
```

**CRITICAL PATH ORDER:**
The line `export PATH="$HOME/.local/bin:$PATH"` must come AFTER any npm or nvm PATH configurations in the shell config file. This ensures `~/.local/bin` is checked first.

### Step 6: Verify Installation

**In a NEW shell (login shell):**

```bash
bash --login -c 'which claude'
# Expected: /home/username/.local/bin/claude
```

**Test the --dsp flag:**

```bash
bash --login -c 'echo "test" | claude --dsp -p "Say: OK"'
# Expected output should include: OK
```

**Test original flag still works:**

```bash
bash --login -c 'echo "test" | claude --dangerously-skip-permissions -p "Say: OK"'
# Expected output should include: OK
```

---

## Common Pitfalls to Avoid

### ❌ DON'T: Modify Claude Binary Directly

```bash
# WRONG - gets reset on npm updates
sed -i 's/something/something/' $(which claude)
```

### ❌ DON'T: Use Shell Aliases

```bash
# WRONG - only works in interactive shells
alias claude='claude --dangerously-skip-permissions'
```

### ❌ DON'T: Create Wrapper Without Proper PATH Configuration

The wrapper is useless if PATH doesn't find it first.

### ❌ DON'T: Forget to Use Heredoc with Single Quotes

```bash
# WRONG - variables will expand during creation
cat > ~/.local/bin/claude << WRAPPER_EOF

# CORRECT - variables preserved literally
cat > ~/.local/bin/claude << 'WRAPPER_EOF'
```

### ❌ DON'T: Hard-code Claude Path Without Fallbacks

Always implement auto-detection with multiple fallback locations.

---

## Testing Protocol

After implementation, verify ALL of these:

1. **Wrapper exists and is executable:**
   ```bash
   ls -la ~/.local/bin/claude
   # Should show: -rwxr-xr-x ... /home/username/.local/bin/claude
   ```

2. **Wrapper is found first in PATH:**
   ```bash
   which claude
   # Should show: /home/username/.local/bin/claude (NOT npm global)
   ```

3. **Both flags work:**
   ```bash
   echo "test" | claude --dsp -p "Say: DSP"
   echo "test" | claude --dangerously-skip-permissions -p "Say: ORIGINAL"
   ```

4. **Wrapper survives npm update:**
   ```bash
   npm update -g @anthropic-ai/claude-code
   which claude
   # Should STILL show: /home/username/.local/bin/claude
   echo "test" | claude --dsp -p "Say: STILL WORKS"
   ```

---

## Troubleshooting Guide for AI

### Problem: "which claude" shows npm path, not wrapper

**Diagnosis:**
```bash
echo "$PATH" | tr ':' '\n' | head -5
```

**Fix:**
PATH order is wrong. The `~/.local/bin` PATH export must come AFTER npm/nvm exports in shell config.

**Correct order in ~/.bashrc:**
```bash
# ... npm or nvm configuration (if any) ...
export PATH="$HOME/.npm-global/bin:$PATH"

# This must come AFTER npm
export PATH="$HOME/.local/bin:$PATH"
```

### Problem: "Cannot find real Claude binary"

**Diagnosis:**
The wrapper can't locate the real Claude installation.

**Fix:**
Find Claude's actual location:
```bash
npm list -g @anthropic-ai/claude-code | grep "@anthropic-ai/claude-code"
```

Add the discovered path to the wrapper's fallback locations.

### Problem: User on Windows with WSL

**Solution:**
The wrapper approach works perfectly on WSL. No special handling needed. Just ensure:
- Using bash (not PowerShell)
- `~/.bashrc` is configured correctly
- Line endings are Unix (LF), not Windows (CRLF)

**Fix line endings if needed:**
```bash
sed -i 's/\r$//' ~/.local/bin/claude
```

### Problem: User uses Zsh instead of Bash

**Solution:**
Same approach, but configure `~/.zshrc` instead of `~/.bashrc`:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

---

## Files to Create in Repository

When implementing this solution, create these files:

### 1. `install-dsp-flag.sh`
Automated installation script that:
- Creates wrapper directory
- Writes wrapper script
- Updates shell configuration
- Verifies installation
- Provides user feedback

### 2. `verify-dsp.sh`
Verification script that:
- Checks wrapper exists
- Verifies PATH configuration
- Tests both --dsp and original flags
- Reports success/failure

### 3. `DSP-FLAG-IMPLEMENTATION.md`
Complete user documentation with:
- Permanent solution (wrapper method) as primary
- Step-by-step manual installation
- One-line automated installation
- Troubleshooting guide
- Legacy binary modification method (deprecated, for reference)

### 4. `AI-IMPLEMENTATION-GUIDE.md` (this file)
Guide for AI assistants implementing this solution

### 5. Updated `README.md`
Quick start section pointing to the solution

---

## Summary: What AI Should Do

When a user asks to implement a permanent `--dsp` flag for Claude:

1. **Understand:** This is a wrapper script approach, NOT binary modification
2. **Create:** Wrapper at `~/.local/bin/claude` using heredoc with single quotes
3. **Configure:** PATH in shell config file (after npm/nvm)
4. **Test:** In a login shell to verify it works
5. **Explain:** Why this persists (separate from npm installation)
6. **Document:** What was done and how to verify/maintain it

**Never** suggest modifying the Claude binary directly. **Always** use the wrapper approach.

---

## Expected User Experience

**After Implementation:**

User opens a NEW terminal:
```bash
$ which claude
/home/username/.local/bin/claude

$ claude --dsp
# Claude starts in dangerously-skip-permissions mode

$ echo "hi" | claude --dsp -p "Say hi"
Hi!
```

**After npm update:**
```bash
$ npm update -g @anthropic-ai/claude-code
# ... npm output ...

$ claude --dsp
# STILL WORKS - wrapper persists
```

**Key Indicator of Success:**
- `which claude` shows `~/.local/bin/claude` (not npm path)
- Both `--dsp` and `--dangerously-skip-permissions` work identically
- Survives npm updates without any reapplication

---

## Additional Context

This implementation was created in response to the problem that the previous approach (modifying the Claude binary with `sed`) was non-permanent and got reset on every npm update. The wrapper approach solves this by:

1. Living outside npm's installation directory
2. Using PATH priority to intercept calls
3. Being transparent to the user and Claude itself
4. Working across all platforms (Linux, macOS, WSL, etc.)

The solution is production-ready, tested, and confirmed working on WSL (Ubuntu on Windows).

---

## Quick Reference Command Sequence

For AI to copy-paste (adapt as needed):

```bash
# Create wrapper directory
mkdir -p ~/.local/bin

# Create wrapper script (use heredoc with single quotes!)
cat > ~/.local/bin/claude << 'WRAPPER_EOF'
#!/bin/bash
REAL_CLAUDE=""
for claude_path in $(which -a claude 2>/dev/null); do
    if [[ "$claude_path" != "$HOME/.local/bin/claude" ]]; then
        REAL_CLAUDE="$claude_path"
        break
    fi
done
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
args=()
for arg in "$@"; do
    if [[ "$arg" == "--dsp" ]]; then
        args+=("--dangerously-skip-permissions")
    else
        args+=("$arg")
    fi
done
exec "$REAL_CLAUDE" "${args[@]}"
WRAPPER_EOF

# Make executable
chmod +x ~/.local/bin/claude

# Add to PATH (if not already)
if ! grep -q '$HOME/.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Verify in new shell
bash --login -c 'which claude'
bash --login -c 'echo "test" | claude --dsp -p "Say: OK"'
```

---

**End of AI Implementation Guide**
