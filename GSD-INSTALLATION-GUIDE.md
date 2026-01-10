# Get Shit Done (GSD) Plugin Installation & Configuration Guide

Complete guide for installing and configuring the GSD (Get Shit Done) plugin for Claude Code on Android/Termux.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Troubleshooting](#troubleshooting)
- [Configuration](#configuration)
- [Usage](#usage)

---

## Overview

**GSD (Get Shit Done)** is a meta-prompting, context engineering, and spec-driven development system for Claude Code. It provides hierarchical project planning optimized for solo agentic development.

**Features:**
- 18+ slash commands for project management
- Phase-based development workflow
- Milestone tracking and completion
- Codebase mapping for brownfield projects
- Research and planning tools
- Context preservation across sessions

**Commands namespace:** `/gsd:`

---

## Installation

### Step 1: Install via NPM

```bash
npx get-shit-done-cc --local
```

This installs the plugin to `./.claude/plugins/marketplaces/get-shit-done/`

**Note:** The installation creates the plugin structure but requires additional configuration to work properly with Claude Code's plugin system.

---

## Troubleshooting

After installation, the commands may not appear or may appear with the wrong namespace. This guide covers all common issues and fixes.

### Issue 1: Commands Not Appearing

**Symptom:** Typing `/gsd:` shows no auto-complete suggestions.

**Root Cause:** The plugin is not registered in Claude Code's marketplace registry.

**Solution:**

1. **Add marketplace registration** to `~/.claude/plugins/known_marketplaces.json`:

```json
{
  "taches-cc-resources": {
    "source": {
      "source": "github",
      "repo": "glittercowboy/taches-cc-resources"
    },
    "installLocation": "/data/data/com.termux/files/home/.claude/plugins/marketplaces/taches-cc-resources",
    "lastUpdated": "2025-12-14T14:11:33.596Z"
  },
  "gsd": {
    "source": {
      "source": "github",
      "repo": "glittercowboy/get-shit-done"
    },
    "installLocation": "/data/data/com.termux/files/home/.claude/plugins/marketplaces/gsd",
    "lastUpdated": "2026-01-10T02:40:00.000Z"
  }
}
```

2. **Create marketplace.json** in plugin directory:

File: `~/.claude/plugins/marketplaces/gsd/.claude-plugin/marketplace.json`

```json
{
  "name": "gsd",
  "owner": {
    "name": "glittercowboy"
  },
  "plugins": [
    {
      "name": "gsd",
      "description": "A meta-prompting, context engineering and spec-driven development system for Claude Code by TÂCHES.",
      "author": {
        "name": "TÂCHES"
      },
      "version": "1.3.20",
      "source": "./"
    }
  ]
}
```

3. **Restart Claude Code** completely (exit and restart, not just `/clear`)

### Issue 2: Wrong Command Namespace

**Symptom:** Commands appear as `/get-shit-done:help` instead of `/gsd:help`

**Root Cause:** The plugin name in configuration files is "get-shit-done" instead of "gsd".

**Solution: Complete Plugin Renaming**

This requires changing the plugin name in **6 locations**:

#### 1. Edit `plugin.json`

File: `~/.claude/plugins/marketplaces/gsd/.claude-plugin/plugin.json`

Change:
```json
{
  "name": "get-shit-done",
  ...
}
```

To:
```json
{
  "name": "gsd",
  ...
}
```

#### 2. Edit `marketplace.json`

File: `~/.claude/plugins/marketplaces/gsd/.claude-plugin/marketplace.json`

Replace ALL occurrences of `"get-shit-done"` with `"gsd"`:

```bash
sed -i 's/"get-shit-done"/"gsd"/g' ~/.claude/plugins/marketplaces/gsd/.claude-plugin/marketplace.json
```

#### 3. Update `installed_plugins.json`

File: `~/.claude/plugins/installed_plugins.json`

Change the key from `"get-shit-done@get-shit-done"` to `"gsd@gsd"`:

```json
{
  "version": 2,
  "plugins": {
    "gsd@gsd": [
      {
        "scope": "user",
        "installPath": "/data/data/com.termux/files/home/.claude/plugins/marketplaces/gsd",
        "version": "1.0.0",
        "installedAt": "2025-12-27T22:06:00.000Z",
        "lastUpdated": "2026-01-10T02:40:00.000Z",
        "isLocal": true
      }
    ]
  }
}
```

#### 4. Update `known_marketplaces.json`

File: `~/.claude/plugins/known_marketplaces.json`

Change the key from `"get-shit-done"` to `"gsd"` (shown in Issue 1 solution).

#### 5. Update `settings.json`

File: `~/.claude/settings.json`

Change the enabledPlugins key:

```json
{
  "enabledPlugins": {
    "taches-cc-resources@taches-cc-resources": true,
    "gsd@gsd": true
  }
}
```

#### 6. Rename the marketplace directory

```bash
mv ~/.claude/plugins/marketplaces/get-shit-done ~/.claude/plugins/marketplaces/gsd
```

#### 7. Restart Claude Code

Exit completely and restart. Test by typing `/gsd:` - you should now see all commands with the short prefix.

---

## Configuration

### Plugin File Structure

After proper configuration, the plugin structure should be:

```
~/.claude/plugins/marketplaces/gsd/
├── .claude-plugin/
│   ├── plugin.json          # name: "gsd"
│   └── marketplace.json     # name: "gsd", plugins[0].name: "gsd"
├── commands/
│   └── gsd/                 # Command files here
│       ├── help.md
│       ├── new-project.md
│       ├── create-roadmap.md
│       ├── plan-phase.md
│       ├── execute-plan.md
│       └── ... (18+ commands)
├── references/
├── templates/
└── workflows/
```

### Command Namespace Logic

Claude Code derives the command namespace from:
1. **Plugin name** (from `plugin.json` "name" field) - Primary namespace
2. **Command subdirectory** (optional) - Secondary namespace

**Examples:**
- Plugin named "gsd" + commands in `commands/gsd/` → `/gsd:help`
- Plugin named "foo" + commands in `commands/` → `/foo:help`
- Plugin named "foo" + commands in `commands/bar/` → `/bar:` (plugin:foo:bar)

**For GSD:** The plugin must be named "gsd" in all config files to get `/gsd:` commands.

---

## Usage

### Available Commands

Once installed, you have access to 18+ GSD commands:

#### Project Initialization
- `/gsd:new-project` - Initialize project with brief
- `/gsd:map-codebase` - Map existing codebase (for brownfield projects)
- `/gsd:create-roadmap` - Create roadmap and phases

#### Phase Planning
- `/gsd:discuss-phase <number>` - Articulate vision for a phase
- `/gsd:research-phase <number>` - Ecosystem research for specialized domains
- `/gsd:plan-phase <number>` - Create detailed execution plan
- `/gsd:list-phase-assumptions <number>` - Preview planned approach

#### Execution
- `/gsd:execute-plan <path>` - Execute a PLAN.md file

#### Roadmap Management
- `/gsd:add-phase <description>` - Add new phase
- `/gsd:insert-phase <after> <description>` - Insert urgent work mid-milestone

#### Milestone Management
- `/gsd:discuss-milestone` - Figure out next milestone features
- `/gsd:new-milestone <name>` - Create new milestone
- `/gsd:complete-milestone <version>` - Archive and tag release

#### Progress & Session Management
- `/gsd:progress` - Check status and route to next action
- `/gsd:pause-work` - Create context handoff
- `/gsd:resume-work` - Resume from previous session

#### Issue Management
- `/gsd:consider-issues` - Review deferred issues

#### Help
- `/gsd:help` - Show command reference

### Quick Start Workflow

**For a new project:**

```
/gsd:new-project
/gsd:create-roadmap
/gsd:plan-phase 1
/gsd:execute-plan .planning/phases/01-foundation/01-01-PLAN.md
```

**For an existing codebase:**

```
/gsd:map-codebase
/gsd:new-project
/gsd:create-roadmap
/gsd:plan-phase 1
```

**Resuming work:**

```
/gsd:progress
```

---

## How Claude Code's Plugin System Works

### Plugin Loading Flow

1. **Marketplace Discovery** - Reads `known_marketplaces.json` to find available marketplaces
2. **Plugin Resolution** - For each marketplace, reads its `marketplace.json` to discover plugins
3. **Plugin Loading** - Reads each plugin's `plugin.json` for metadata
4. **Command Registration** - Scans `commands/` directory for `.md` files and registers them
5. **Enablement Check** - Only loads plugins marked as enabled in `settings.json`

### Key Configuration Files

| File | Purpose |
|------|---------|
| `known_marketplaces.json` | Registry of available marketplaces (GitHub repos) |
| `installed_plugins.json` | Tracks installed plugins and their paths |
| `settings.json` | Which plugins are enabled/disabled |
| `.claude-plugin/marketplace.json` | Marketplace manifest defining available plugins |
| `.claude-plugin/plugin.json` | Individual plugin metadata |

### Plugin Naming Convention

Plugin identifiers use the format: `{name}@{marketplace}`

For GSD:
- Marketplace name: `gsd`
- Plugin name: `gsd`
- Full identifier: `gsd@gsd`

This identifier must be consistent across:
- `known_marketplaces.json` key
- `installed_plugins.json` key
- `settings.json` enabledPlugins key
- `marketplace.json` name field
- `plugin.json` name field

---

## Verification Steps

After installation and configuration, verify everything works:

### 1. Check Plugin Registration

```bash
cat ~/.claude/plugins/known_marketplaces.json | grep -A 7 "gsd"
```

Expected output:
```json
"gsd": {
  "source": {
    "source": "github",
    "repo": "glittercowboy/get-shit-done"
  },
  "installLocation": "/data/data/com.termux/files/home/.claude/plugins/marketplaces/gsd",
  "lastUpdated": "2026-01-10T02:40:00.000Z"
}
```

### 2. Check Plugin Enablement

```bash
cat ~/.claude/settings.json | grep "gsd"
```

Expected output:
```json
"gsd@gsd": true
```

### 3. Check Command Files

```bash
ls ~/.claude/plugins/marketplaces/gsd/commands/gsd/ | wc -l
```

Expected: 18 or more `.md` files

### 4. Test Commands

1. Restart Claude Code
2. Type `/gsd:`
3. Auto-complete should show all GSD commands

### 5. Run Help Command

```
/gsd:help
```

Should display the complete GSD command reference.

---

## Common Issues & Solutions

### Commands Still Show `/get-shit-done:`

**Cause:** Plugin name not fully renamed in all configuration files.

**Solution:** Check all 6 locations listed in "Issue 2: Wrong Command Namespace" and ensure every occurrence of "get-shit-done" is changed to "gsd".

### Plugin Not Loading After Restart

**Cause:** Missing or malformed JSON in configuration files.

**Solution:** Validate JSON syntax:

```bash
python -m json.tool ~/.claude/plugins/known_marketplaces.json
python -m json.tool ~/.claude/plugins/installed_plugins.json
python -m json.tool ~/.claude/settings.json
```

### Commands Appear But Don't Execute

**Cause:** Command files are in wrong location or have incorrect format.

**Solution:** Ensure commands are in `~/.claude/plugins/marketplaces/gsd/commands/gsd/` and have proper YAML frontmatter:

```yaml
---
description: Command description here
---
```

---

## Resources

- **GitHub Repository:** https://github.com/glittercowboy/get-shit-done
- **NPM Package:** https://www.npmjs.com/package/get-shit-done-cc
- **Documentation:** Run `/gsd:help` in Claude Code

---

## Troubleshooting Checklist

If GSD commands aren't working, check:

- [ ] Plugin directory exists at `~/.claude/plugins/marketplaces/gsd/`
- [ ] Marketplace registered in `known_marketplaces.json` with key "gsd"
- [ ] Plugin registered in `installed_plugins.json` with key "gsd@gsd"
- [ ] Plugin enabled in `settings.json` with key "gsd@gsd": true
- [ ] `plugin.json` has `"name": "gsd"`
- [ ] `marketplace.json` has `"name": "gsd"` (both places)
- [ ] Command files exist in `commands/gsd/` subdirectory
- [ ] Claude Code has been restarted after configuration changes
- [ ] All JSON files have valid syntax (no trailing commas, proper quotes)

---

## Advanced: Manual Installation Script

For automated setup, you can use this bash script:

```bash
#!/bin/bash

# GSD Plugin Installation & Configuration Script
# Installs and configures GSD plugin with correct namespace

CLAUDE_DIR="$HOME/.claude"
PLUGIN_DIR="$CLAUDE_DIR/plugins/marketplaces/gsd"

echo "Installing GSD plugin..."

# 1. Install via NPX
npx get-shit-done-cc --local

# 2. Rename directory if needed
if [ -d "$CLAUDE_DIR/plugins/marketplaces/get-shit-done" ]; then
    mv "$CLAUDE_DIR/plugins/marketplaces/get-shit-done" "$PLUGIN_DIR"
fi

# 3. Update plugin.json
sed -i 's/"name": "get-shit-done"/"name": "gsd"/' "$PLUGIN_DIR/.claude-plugin/plugin.json"

# 4. Update marketplace.json
sed -i 's/"get-shit-done"/"gsd"/g' "$PLUGIN_DIR/.claude-plugin/marketplace.json"

# 5. Add to known_marketplaces.json
# (Manual step - requires careful JSON editing)

# 6. Update installed_plugins.json
# (Manual step - requires careful JSON editing)

# 7. Update settings.json
# (Manual step - requires careful JSON editing)

echo "Plugin installed. Please:"
echo "1. Manually update known_marketplaces.json"
echo "2. Manually update installed_plugins.json"
echo "3. Manually update settings.json"
echo "4. Restart Claude Code"
echo ""
echo "See GSD-INSTALLATION-GUIDE.md for details."
```

---

## Changelog

### v1.0 (2026-01-10)
- Initial guide creation
- Documented complete installation process
- Documented all 6 configuration file changes for namespace fix
- Added troubleshooting section
- Added verification steps
- Explained Claude Code plugin system architecture

---

**Created:** 2026-01-10
**Author:** TÂCHES / tpdhd
**License:** MIT
