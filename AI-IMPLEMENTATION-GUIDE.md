# AI Implementation Guide: --dsp Flag for Claude Code

## For AI Assistants

This guide provides instructions for AI assistants implementing the permanent `--dsp` flag for Claude Code users.

**User-facing documentation:** See [DSP-FLAG-IMPLEMENTATION.md](./DSP-FLAG-IMPLEMENTATION.md) for complete details.

---

## Quick Decision Tree

When a user asks to implement `--dsp` flag:

1. **Ask about their environment:**
   - What shell? (bash, zsh, fish, etc.)
   - What OS? (Linux, macOS, WSL, etc.)
   - Do they need it in shell scripts or only interactive use?

2. **Choose method:**
   - **Bash only, interactive use** → Bash Function Method (fastest)
   - **Multiple shells, scripts, production** → Wrapper Script Method (most robust)

3. **Implement and verify**

---

## Method 1: Bash Function (Recommended for Most Users)

### When to Use

- User is on bash (most Linux/WSL users)
- Personal use, not production
- Interactive shell only
- Want fastest setup

### Implementation

```bash
# Add to ~/.bashrc
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

# Reload shell
source ~/.bashrc
```

### Verification

```bash
# Test function exists
type claude
# Should output: "claude is a function"

# Test it works
echo "test" | claude --dsp -p "Say: Working!"
```

### Key Points for AI

- Use heredoc with **single quotes** (`'EOF'`) to prevent variable expansion
- Use `command claude` inside function to avoid infinite recursion
- Must reload shell with `source ~/.bashrc` after adding
- This is permanent across reboots (saved in .bashrc)

---

## Method 2: Wrapper Script

### When to Use

- User needs it in zsh, fish, or multiple shells
- Needs to work in non-interactive shells
- Needs to work in shell scripts
- Production environment

### Implementation

```bash
# 1. Create wrapper directory
mkdir -p ~/.local/bin

# 2. Create wrapper script
cat > ~/.local/bin/claude << 'EOF'
#!/bin/bash

# Find the real Claude binary (skip our wrapper)
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

# 4. Add to PATH (bash example)
if ! grep -q '$HOME/.local/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# 5. Reload
source ~/.bashrc
```

### Verification

```bash
# Check wrapper is found first
which claude
# Should output: /home/username/.local/bin/claude (NOT npm path)

# Test it works
echo "test" | claude --dsp -p "Say: Working!"
```

### Key Points for AI

- PATH configuration must come AFTER npm/nvm in shell config
- Use `which -a` to find real Claude and skip our wrapper
- Use `exec` to replace wrapper process (cleaner)
- Test in a NEW shell to verify PATH is correct

---

## Common Pitfalls to Avoid

### ❌ DON'T: Modify Claude Binary Directly

```bash
# WRONG - gets reset on npm updates
sed -i 's/something/something/' $(which claude)
```

### ❌ DON'T: Use Simple Aliases

```bash
# WRONG - creates new command, doesn't expand --dsp flag
alias dsp='claude --dangerously-skip-permissions'
```

This creates a `dsp` command, not a `--dsp` flag.

### ❌ DON'T: Forget Heredoc Quotes

```bash
# WRONG - variables expand during creation
cat > file << EOF

# CORRECT - variables preserved
cat > file << 'EOF'
```

### ❌ DON'T: Skip Verification

Always test in a NEW shell after implementation to ensure it persists.

---

## Troubleshooting Guide

### Issue: "which claude" shows npm path, not wrapper

**Cause:** PATH order incorrect

**Fix:**
```bash
# Check PATH order
echo "$PATH" | tr ':' '\n' | head -5

# ~/.local/bin must appear BEFORE npm directories
# If not, edit ~/.bashrc and move PATH export AFTER npm config
```

### Issue: Function not found after adding to .bashrc

**Cause:** Shell not reloaded

**Fix:**
```bash
source ~/.bashrc
# Or open new terminal
```

### Issue: "Cannot find real Claude binary"

**Cause:** Claude in non-standard location

**Fix:**
```bash
# Find it
npm list -g @anthropic-ai/claude-code

# Update wrapper with correct path
nano ~/.local/bin/claude
# Edit REAL_CLAUDE variable or add to fallback paths
```

---

## Platform-Specific Notes

### WSL (Windows Subsystem for Linux)

- Works perfectly with bash function method
- Default shell is usually bash
- Verify with: `echo $SHELL`

### macOS

- Default shell changed to zsh in Catalina+
- Check with: `echo $SHELL`
- If zsh: Use wrapper script method OR add function to `~/.zshrc`

### Linux

- Usually bash by default
- Bash function method works great
- Some distros use zsh (Manjaro, etc.) - check shell first

---

## Testing Protocol

After implementation, verify ALL of these:

```bash
# 1. Check implementation type
# For bash function:
type claude          # Should say "claude is a function"

# For wrapper script:
which claude         # Should show ~/.local/bin/claude
ls -l ~/.local/bin/claude   # Should exist and be executable

# 2. Test --dsp flag
echo "test" | claude --dsp -p "Say: DSP"
# Should output: DSP (or similar)

# 3. Test original flag still works
echo "test" | claude --dangerously-skip-permissions -p "Say: ORIGINAL"
# Should output: ORIGINAL (or similar)

# 4. Test in new shell (important!)
bash --login -c 'echo "test" | claude --dsp -p "Say: NEW SHELL"'
# Should work without errors
```

---

## Summary for AI

1. **Prefer Bash Function Method** for most users (simpler, faster)
2. **Use Wrapper Script Method** for advanced needs (multiple shells, scripts)
3. **Never modify** the Claude binary directly
4. **Always test** in a new shell after implementation
5. **Explain permanence** - both methods survive npm updates
6. **Use heredocs** with single quotes to prevent variable expansion

---

## Quick Reference Commands

### Bash Function Method
```bash
cat >> ~/.bashrc << 'EOF'

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

### Test Command
```bash
echo "test" | claude --dsp -p "Say: OK"
```

---

**Full documentation:** [DSP-FLAG-IMPLEMENTATION.md](./DSP-FLAG-IMPLEMENTATION.md)
