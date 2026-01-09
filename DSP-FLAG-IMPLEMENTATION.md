# --dsp Flag Implementation Guide

## CRITICAL UNDERSTANDING

This guide explains how to ADD THE --dsp FLAG DIRECTLY TO CLAUDE CODE BINARY.

**DO NOT confuse this with creating shell aliases!**

- Shell alias: Creates `dsp` command that calls `claude --dangerously-skip-permissions`
- This guide: Modifies Claude binary to accept `--dsp` as a built-in flag

## What This Does

After implementation:
- `claude --dsp` will work (NEW)
- `claude --dangerously-skip-permissions` will still work (UNCHANGED)
- Both flags do the EXACT same thing

---

## Prerequisites

1. Claude Code must be installed
2. You need write permissions to the Claude binary file
3. You need basic command line access

---

## Step 1: Find Claude Binary Location

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

---

## Step 2: Create Backup

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

---

## Step 3: Modify Claude Binary

**You need to make THREE changes to the Claude binary file.**

### Change 1: Add --dsp Option Definition

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

---

### Change 2: Add dsp to Parameter Destructuring

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

---

### Change 3: Combine Both Flags

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

---

## Step 4: Verify Changes

### Verification 1: Check Help Output

**Command:**
```bash
claude --help | grep -A 1 "dsp"
```

**Expected Output:**
```
  --dsp                                             Shorthand for --dangerously-skip-permissions.
```

If you see this, the flag was added successfully.

---

### Verification 2: Test --dsp Flag

**Command:**
```bash
echo "test" | claude --dsp -p "what is 2+2?"
```

**Expected Output:**
```
2 + 2 = 4
```

If this works, the flag is functioning correctly.

---

### Verification 3: Test Original Flag Still Works

**Command:**
```bash
echo "test" | claude --dangerously-skip-permissions -p "what is 3+3?"
```

**Expected Output:**
```
3 + 3 = 6
```

Both flags should work identically.

---

## Complete Implementation Script

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
```

---

## Troubleshooting

### Problem: "sed: can't read: No such file or directory"

**Cause:** Claude path is incorrect or Claude is not installed.

**Solution:** Run `which claude` to verify Claude location.

---

### Problem: Changes don't take effect

**Cause:** Binary file is cached or protected.

**Solution:**
1. Close all Claude instances
2. Clear any shell hash: `hash -r`
3. Try running Claude from full path: `$CLAUDE_PATH --help`

---

### Problem: "--dsp" not showing in help

**Cause:** First sed command failed.

**Solution:**
1. Restore from backup: `cp <CLAUDE_PATH>.backup <CLAUDE_PATH>`
2. Re-run Step 3, Change 1
3. Check for typos in the command

---

### Problem: "--dsp" shows in help but doesn't work

**Cause:** Changes 2 or 3 failed.

**Solution:**
1. Verify Change 2 was applied:
   ```bash
   grep -o "dsp:dspFlag" <CLAUDE_PATH>
   ```
   Should output: `dsp:dspFlag`

2. Verify Change 3 was applied:
   ```bash
   grep -o "K=K||dspFlag" <CLAUDE_PATH>
   ```
   Should output: `K=K||dspFlag`

3. If either is missing, restore backup and re-apply all changes

---

## Restore Original Claude

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

---

## Technical Explanation

### What Each Change Does

**Change 1:** Adds the `--dsp` flag to Commander.js options
- Makes CLI parser recognize `--dsp` as a valid flag
- Sets the description shown in `--help` output

**Change 2:** Extracts the `dsp` flag value from parsed options
- Creates variable `dspFlag` containing the value of `--dsp`
- Must match the flag name exactly (dsp = dsp)

**Change 3:** Combines both flags using OR operator
- `K=K||dspFlag` means: "If --dangerously-skip-permissions is set, use it; otherwise use --dsp"
- Both flags affect the same variable `K`
- Variable `K` controls permission bypass mode

---

## File Location Reference

### Common Claude Binary Locations

**Linux with npm global:**
```
/home/<username>/.npm-global/bin/claude
```

**Linux with system npm:**
```
/usr/local/bin/claude
```

**WSL (Windows Subsystem for Linux):**
```
/home/<username>/.npm-global/bin/claude
```

**macOS with npm global:**
```
/Users/<username>/.npm-global/bin/claude
```

**macOS with Homebrew:**
```
/usr/local/bin/claude
/opt/homebrew/bin/claude
```

**Termux (Android):**
```
/data/data/com.termux/files/usr/bin/claude
```

---

## Important Notes

1. **This modifies the Claude binary directly** - changes persist until Claude is updated/reinstalled
2. **Backup is mandatory** - always create backup before modifying
3. **Updates will overwrite changes** - re-apply after Claude updates
4. **Works on all platforms** - same approach for Linux, macOS, WSL, Termux
5. **No shell configuration needed** - this is NOT a shell alias
6. **Changes are immediate** - no need to restart terminal or reload config files

---

## For AI Implementation

When implementing this:
1. **Always** get Claude path first using `which claude`
2. **Always** create backup before any modifications
3. **Apply all three changes** - all are required for the flag to work
4. **Verify after each change** - helps identify which step failed
5. **Test both flags** - ensure neither broke the other

**Critical:** Do not confuse this with shell alias creation. This modifies the Claude binary file itself.
