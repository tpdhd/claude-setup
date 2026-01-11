# Claude Code Notification Sound for Multiple Choice Questions

## Problem Statement

Claude Code has a built-in hook system that plays a notification sound when tasks complete (using the `Stop` hook). However, **there is no hook that triggers when Claude displays multiple choice questions** that require user interaction with arrow keys.

This creates a usability issue: users working in other windows won't know when Claude is waiting for their input on a multiple choice question.

## Research Findings

### Available Hooks Investigation

We investigated all available Claude Code hooks to find a solution:

#### 1. Stop Hook ✅ (Working)
- **Triggers:** When Claude finishes responding
- **Status:** Already implemented and working
- **Limitation:** Does NOT fire when Claude pauses mid-response for user input

#### 2. Notification Hook ❌ (Doesn't Work for Our Use Case)
- **Triggers:** Only when:
  - Claude needs permission to use a tool
  - Prompt has been idle for 60+ seconds
- **Status:** Does NOT trigger for AskUserQuestion tool
- **Tested:** Confirmed it doesn't fire for multiple choice prompts

#### 3. PreToolUse Hook ❌ (Broken)
- **Triggers:** Before every tool execution
- **Problem:** Environment variables (`CLAUDE_TOOL_NAME`, `CLAUDE_TOOL_INPUT`) are not populated
- **GitHub Issue:** [#9567](https://github.com/anthropics/claude-code/issues/9567) - Closed as "Not Planned" (Jan 8, 2026)
- **Impact:** Cannot filter by tool type, making it impossible to detect AskUserQuestion specifically

#### 4. UserInputRequired Hook ❌ (Doesn't Exist)
- **Status:** Feature requested but not implemented
- **GitHub Issue:** [#10168](https://github.com/anthropics/claude-code/issues/10168) - Open with 23+ upvotes
- **What it would do:** Trigger when Claude pauses and waits for user input
- **Workaround:** None available through official hooks

### Root Cause

The Claude Code hooks system has two critical limitations:

1. **No hook exists for AskUserQuestion tool calls** - There's no event that fires when multiple choice prompts are displayed
2. **Hook environment variables are broken** - Even if PreToolUse fired, we can't identify which tool is being used

## Solution: Output Pattern Detection

Since the hook system cannot detect multiple choice questions, we implemented a wrapper script that monitors Claude's terminal output in real-time.

### How It Works

```
User runs: claude
    ↓
claude-with-sound wrapper starts
    ↓
    ├── Spawns claude-monitor.sh in background
    ├── Runs: script -q -f -c "claude ..." /tmp/claude-monitor/output.log
    │   (Captures output while maintaining full interactivity)
    └── claude-monitor.sh watches the log file
        └── When pattern matches → plays notification sound
```

### The Magic Pattern

After analyzing actual Claude Code output with `cat -A` on log files, we discovered the exact pattern that uniquely identifies multiple choice prompts:

```
Enter to select ● ↑/↓ to navigate ● Esc to cancel
```

This instruction line **only** appears when Claude displays a multiple choice question using the AskUserQuestion tool.

#### Pattern Detection

The monitor script uses this regex:
```bash
"Enter to select.*to navigate"
```

This pattern is:
- ✅ **Highly specific** - Only matches actual multiple choice prompts
- ✅ **Reliable** - Always present in AskUserQuestion output
- ❌ **Never triggers on** - Regular questions, typing, or normal conversation

### Technical Implementation

#### File Structure
```
~/.claude/
├── claude-with-sound          # Main wrapper script
├── claude-monitor.sh           # Pattern detection script
├── notify-sound.js             # Sound playback (already existed)
├── debug-hook.sh              # Debug logging
└── settings.json              # Claude hooks configuration
```

#### Key Components

**1. claude-with-sound** (Wrapper)
- Uses Linux `script` command with `-c` flag for command execution
- Properly escapes arguments with `printf %q`
- Uses full path to Claude binary to avoid recursive calls
- Creates temporary log file in `/tmp/claude-monitor/`
- Spawns monitor in background
- Cleans up on exit

**2. claude-monitor.sh** (Pattern Detector)
- Waits up to 5 seconds for log file creation
- Uses `tail -f` to monitor log in real-time
- Checks each line against pattern with `grep -E -i`
- Has 3-second cooldown to prevent sound spam
- Exits silently if log file doesn't exist

**3. Modified .bashrc**
```bash
# Claude wrapper function to support --dsp shortcut and sound notifications
claude() {
  local args=()
  for arg in "$@"; do
    if [ "$arg" = "--dsp" ]; then
      args+=("--dangerously-skip-permissions")
    else
      args+=("$arg")
    fi
  done
  "$HOME/.claude/claude-with-sound" "${args[@]}"
}
```

### Pattern Evolution

We went through several iterations to find the right pattern:

#### ❌ Too Broad (Caused False Positives)
```bash
"Choose"              # Matched any mention of choosing
"\?"                  # Matched every question
"press.*Enter"        # Too common
"Select.*option"      # Too generic
```

#### ❌ Too Specific (Missed Valid Cases)
```bash
"Use ↑/↓ arrow"      # Required exact Unicode characters
"›\s+[A-Za-z]"       # Not always present
```

#### ✅ Just Right (Final Solution)
```bash
"Enter to select.*to navigate"  # Unique to multiple choice prompts
```

## Installation

### Files Created

All scripts are in `~/.claude/`:

1. **claude-with-sound** (Wrapper)
2. **claude-monitor.sh** (Monitor)
3. **setup-sound-alias.sh** (Installer)

### Setup Command

```bash
bash ~/.claude/setup-sound-alias.sh
source ~/.bashrc
```

### Verification

Test the wrapper:
```bash
# Should show Claude version, not script version
claude --version
# Output: 2.1.4 (Claude Code)

# Test sound manually
node ~/.claude/notify-sound.js
```

## Testing Results

### What Triggers Sound ✅
- Multiple choice questions with arrow key navigation
- Any AskUserQuestion tool call

### What Does NOT Trigger Sound ✅
- Normal typing
- Regular questions (ending with ?)
- Conversation
- Startup messages
- Stop hook events (those use the existing hook)

### Test Case
```bash
# In Claude, trigger a multiple choice:
claude> "Give me a multiple choice question"

# Output shows:
Enter to select ● ↑/↓ to navigate ● Esc to cancel
# 🔊 Sound plays!
```

## Technical Challenges Solved

### 1. Script Command Argument Parsing
**Problem:** The `script` command was intercepting `--version` flag meant for Claude

**Solution:** Use `--` separator and proper argument escaping with `printf %q`

### 2. Recursive Wrapper Calls
**Problem:** Wrapper was calling itself instead of actual Claude binary

**Solution:** Use full path to Claude: `$HOME/.npm-global/bin/claude`

### 3. Linux vs BSD Script Detection
**Problem:** Wrong syntax was being used (BSD instead of Linux)

**Solution:** Check for "util-linux" in `script --version` output

### 4. Log File Race Condition
**Problem:** Monitor started before log file existed, causing `tail` errors

**Solution:** Wait up to 5 seconds for file creation with retry loop

### 5. Windows Line Endings
**Problem:** Scripts had `\r\n` endings, causing bash syntax errors

**Solution:** Run `sed -i 's/\r$//'` on all scripts

## Limitations & Future Improvements

### Current Limitations

1. **Output monitoring overhead** - Minimal but present (uses `script` command and `tail -f`)
2. **Requires `script` command** - Falls back to direct execution if unavailable
3. **Pattern-based detection** - Could break if Claude changes the UI text
4. **3-second cooldown** - Prevents rapid consecutive sounds

### Future Improvements

When Claude Code implements official support (Issue #10168), we can:
- Replace output monitoring with native hook
- Reduce overhead
- Get more reliable detection
- Access structured data instead of text patterns

### Alternative Approaches Considered

1. ❌ **node-pty wrapper** - Requires additional npm package dependency
2. ❌ **Terminal emulator triggers** - Only works in specific terminals (iTerm2)
3. ❌ **Manual hook calling** - No API to detect when question is shown
4. ✅ **Output monitoring** - Works reliably without dependencies

## References & Sources

### GitHub Issues
- [Issue #10168: Add hook for user input events](https://github.com/anthropics/claude-code/issues/10168) - Feature request for UserInputRequired hook
- [Issue #9567: Hook environment variables empty](https://github.com/anthropics/claude-code/issues/9567) - Bug preventing PreToolUse filtering

### Documentation
- [Claude Code Hooks Documentation](https://code.claude.com/docs/en/hooks)
- [Claude Code CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [Handle approvals and user input - Claude Docs](https://platform.claude.com/docs/en/agent-sdk/user-input)

### Technical Resources
- [Terminal Bell Character Implementation](https://rosettacode.org/wiki/Terminal_control/Ringing_the_terminal_bell)
- [Interactive CLI Prompts in Go](https://dev.to/tidalcloud/interactive-cli-prompts-in-go-3bj9)
- [Writing an interactive CLI menu in Golang](https://medium.com/@nexidian/writing-an-interactive-cli-menu-in-golang-d6438b175fb6)

## Pattern Analysis Details

### Raw Output Sample

When Claude shows a multiple choice question, the terminal output contains:

```
Enter to select ● ↑/↓ to navigate ● Esc to cancel
```

With ANSI codes visible (via `cat -A`):
```
^[[38;5;246mEnter to select M-BM-7 M-bM-^FM-^Q/M-bM-^FM-^S to navigate M-BM-7 Esc to cancel^[[39m
```

The pattern `"Enter to select.*to navigate"` successfully matches this regardless of ANSI escape codes.

### Why This Pattern Works

1. **Uniqueness** - This exact phrase only appears in multiple choice prompts
2. **Consistency** - Always present in AskUserQuestion tool output
3. **Stability** - Part of the core UI, unlikely to change
4. **Language-agnostic** - Uses regex wildcard for flexibility

## Maintenance

### Log Cleanup

Logs are automatically cleaned:
```bash
# In claude-with-sound script:
find "$LOG_DIR" -name "claude-output-*.log" -mtime +1 -delete 2>/dev/null
```

Files older than 1 day are removed.

### Manual Cleanup

```bash
# Remove all monitor logs
rm -rf /tmp/claude-monitor/

# Test monitor script
bash ~/.claude/claude-monitor.sh /tmp/test.log &
echo "Enter to select ● test to navigate" >> /tmp/test.log
# Should hear sound after ~1 second
```

## Troubleshooting

### Sound not playing on multiple choice

1. **Check pattern detection:**
   ```bash
   tail -f /tmp/claude-monitor/claude-output-*.log
   # Should see the "Enter to select" line when question appears
   ```

2. **Test sound manually:**
   ```bash
   node ~/.claude/notify-sound.js
   ```

3. **Verify wrapper is running:**
   ```bash
   ps aux | grep claude-monitor
   # Should show monitor process
   ```

### Sound playing too often

Check the pattern in `~/.claude/claude-monitor.sh`:
```bash
grep "PATTERNS=" ~/.claude/claude-monitor.sh
# Should only show: "Enter to select.*to navigate"
```

### Wrapper not being used

```bash
# Check .bashrc function
type claude
# Should show function calling claude-with-sound

# Reload shell
source ~/.bashrc
```

## Conclusion

This solution successfully provides sound notifications for Claude Code multiple choice questions despite the lack of official hook support. The output monitoring approach is reliable, specific, and maintains full terminal interactivity.

Once Claude Code implements a native `UserInputRequired` hook (Issue #10168), this system can be easily migrated to use the official API instead of pattern matching.

---

**Last Updated:** January 11, 2026
**Claude Code Version Tested:** 2.1.4
**Platform:** Linux (WSL2 Ubuntu) with util-linux script command
