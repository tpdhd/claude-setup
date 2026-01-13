# TT Commands Installation Guide

## Overview

This guide documents how to install the TÂCHES Claude Code resources (taches-cc-resources) with a shortened `/tt:*` command namespace instead of the default long plugin namespace.

**Source Repository:** https://github.com/glittercowboy/taches-cc-resources

**Problem:** When installed via the plugin system, commands get long prefixes like `/taches-cc-resources:command` or doubled prefixes like `/tt:tt:command`.

**Solution:** Bypass the plugin system entirely and install commands directly to `~/.claude/commands/tt/`.

---

## Quick Installation (One-Command)

```bash
git clone https://github.com/glittercowboy/taches-cc-resources.git /tmp/taches-cc-resources && \
mkdir -p ~/.claude/commands/tt ~/.claude/skills && \
cp /tmp/taches-cc-resources/commands/*.md ~/.claude/commands/tt/ && \
cp -r /tmp/taches-cc-resources/commands/consider ~/.claude/commands/tt/ && \
cp -r /tmp/taches-cc-resources/skills/* ~/.claude/skills/ && \
rm -rf /tmp/taches-cc-resources && \
echo "TT commands installed. Restart Claude Code."
```

---

## Step-by-Step Installation (For AI Agents)

### Step 1: Clone the Source Repository

```bash
git clone https://github.com/glittercowboy/taches-cc-resources.git /tmp/taches-cc-resources
```

### Step 2: Create Target Directories

```bash
mkdir -p ~/.claude/commands/tt
mkdir -p ~/.claude/skills
```

### Step 3: Copy Commands to tt Namespace

Copy all command markdown files to `~/.claude/commands/tt/`:

```bash
cp /tmp/taches-cc-resources/commands/*.md ~/.claude/commands/tt/
```

Copy the `consider` subdirectory (contains thinking model commands):

```bash
cp -r /tmp/taches-cc-resources/commands/consider ~/.claude/commands/tt/
```

### Step 4: Copy Skills

```bash
cp -r /tmp/taches-cc-resources/skills/* ~/.claude/skills/
```

### Step 5: Cleanup

```bash
rm -rf /tmp/taches-cc-resources
```

### Step 6: Restart Claude Code

Commands will not appear until Claude Code is restarted.

---

## Resulting Structure

```
~/.claude/
├── commands/
│   └── tt/
│       ├── add-to-todos.md
│       ├── audit-skill.md
│       ├── audit-slash-command.md
│       ├── audit-subagent.md
│       ├── check-todos.md
│       ├── create-agent-skill.md
│       ├── create-hook.md
│       ├── create-meta-prompt.md
│       ├── create-plan.md
│       ├── create-prompt.md
│       ├── create-slash-command.md
│       ├── create-subagent.md
│       ├── debug.md
│       ├── heal-skill.md
│       ├── run-plan.md
│       ├── run-prompt.md
│       ├── whats-next.md
│       └── consider/
│           ├── 10-10-10.md
│           ├── 5-whys.md
│           ├── eisenhower-matrix.md
│           ├── first-principles.md
│           ├── inversion.md
│           ├── occams-razor.md
│           ├── one-thing.md
│           ├── opportunity-cost.md
│           ├── pareto.md
│           ├── second-order.md
│           ├── swot.md
│           └── via-negativa.md
└── skills/
    ├── create-agent-skills/
    ├── create-hooks/
    ├── create-meta-prompts/
    ├── create-plans/
    ├── create-slash-commands/
    ├── create-subagents/
    ├── debug-like-expert/
    └── expertise/
```

---

## Available Commands After Installation

### Main Commands (`/tt:*`)

| Command | Description |
|---------|-------------|
| `/tt:create-prompt` | Generate optimized prompts for sub-agent execution |
| `/tt:run-prompt` | Execute a generated prompt in sub-agent context |
| `/tt:create-plan` | Invoke hierarchical project planning |
| `/tt:run-plan` | Execute a plan file |
| `/tt:add-to-todos` | Capture context mid-work for later |
| `/tt:check-todos` | Review and resume captured todos |
| `/tt:whats-next` | Create context handoff document |
| `/tt:create-agent-skill` | Build new agent skills |
| `/tt:create-hook` | Build event-driven automation |
| `/tt:create-meta-prompt` | Generate workflow prompts |
| `/tt:create-slash-command` | Build custom slash commands |
| `/tt:create-subagent` | Build specialized sub-agents |
| `/tt:audit-skill` | Validate skill quality |
| `/tt:audit-slash-command` | Validate command quality |
| `/tt:audit-subagent` | Validate sub-agent configuration |
| `/tt:heal-skill` | Fix broken skills |
| `/tt:debug` | Systematic debugging methodology |

### Thinking Model Commands (`/tt:consider:*`)

| Command | Mental Framework |
|---------|-----------------|
| `/tt:consider:pareto` | 80/20 principle analysis |
| `/tt:consider:first-principles` | Break down to fundamentals |
| `/tt:consider:inversion` | Think backwards from failure |
| `/tt:consider:second-order` | Consider downstream effects |
| `/tt:consider:5-whys` | Root cause analysis |
| `/tt:consider:occams-razor` | Simplest explanation |
| `/tt:consider:one-thing` | Identify the keystone |
| `/tt:consider:swot` | Strengths/Weaknesses/Opportunities/Threats |
| `/tt:consider:eisenhower-matrix` | Urgent vs Important |
| `/tt:consider:10-10-10` | Short/medium/long term impact |
| `/tt:consider:opportunity-cost` | What you give up |
| `/tt:consider:via-negativa` | Remove to improve |

---

## Why This Method Works

### The Plugin System Problem

Claude Code's plugin system creates command namespaces from:
1. Marketplace name (from `marketplace.json`)
2. Plugin name (from `plugin.json`)
3. Subdirectory structure under `commands/`

When all are set to the same value (e.g., "tt"), you get doubled prefixes: `/tt:tt:command`.

When marketplace and plugin names differ, the plugin may not load correctly.

### The Direct Installation Solution

By copying commands directly to `~/.claude/commands/tt/`:
- The folder name `tt` becomes the namespace prefix
- No plugin system overhead or configuration files needed
- Clean `/tt:command` namespace
- Subfolders create sub-namespaces (e.g., `consider/` → `/tt:consider:*`)

---

## Verification

After restarting Claude Code, verify installation:

```bash
# Count main commands (should be 17)
ls ~/.claude/commands/tt/*.md | wc -l

# Count consider commands (should be 12)
ls ~/.claude/commands/tt/consider/*.md | wc -l

# Count skills (should be 8)
ls ~/.claude/skills/ | wc -l
```

Test in Claude Code by typing `/tt:` - autocomplete should show available commands.

---

## Uninstallation

```bash
rm -rf ~/.claude/commands/tt
rm -rf ~/.claude/skills/create-agent-skills
rm -rf ~/.claude/skills/create-hooks
rm -rf ~/.claude/skills/create-meta-prompts
rm -rf ~/.claude/skills/create-plans
rm -rf ~/.claude/skills/create-slash-commands
rm -rf ~/.claude/skills/create-subagents
rm -rf ~/.claude/skills/debug-like-expert
rm -rf ~/.claude/skills/expertise
```

---

## Credits

- **TÂCHES Resources:** https://github.com/glittercowboy/taches-cc-resources
- **Author:** Lex Christopherson (glittercowboy)
- **Installation Method:** Direct namespace bypass documented by tpdhd/claude-setup

---

**Document Version:** 1.0.0
**Last Updated:** 2026-01-13
