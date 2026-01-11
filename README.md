# Claude Setup

Collection of utilities and configurations for enhancing Claude Code CLI experience.

## Contents

### 1. [Multiple Choice Notification Sound](NOTIFICATION-SOUND-MULTIPLE-CHOICE.md)

Sound notifications when Claude displays multiple choice questions requiring arrow key navigation.

**Problem:** Claude Code's hook system doesn't fire when displaying interactive prompts
**Solution:** Output monitoring wrapper that detects multiple choice patterns

[→ Full Documentation](NOTIFICATION-SOUND-MULTIPLE-CHOICE.md)

### 2. Claude Account Switcher

Utilities for switching between multiple Claude Code accounts.

Located in: [`claude-account-switcher/`](claude-account-switcher/)

## Quick Start

### Notification Sound Setup

```bash
# Run the setup script
bash ~/.claude/setup-sound-alias.sh

# Reload your shell
source ~/.bashrc

# Test it
claude
```

### Features

- ✅ Sound on task completion (built-in Stop hook)
- ✅ Sound on multiple choice questions (custom monitoring)
- ✅ Preserves `--dsp` shortcut
- ✅ Maintains full terminal interactivity

## Requirements

- Linux with util-linux `script` command
- Node.js (for sound playback)
- Bash shell

## Contributing

Contributions welcome! Please read [NOTIFICATION-SOUND-MULTIPLE-CHOICE.md](NOTIFICATION-SOUND-MULTIPLE-CHOICE.md) for technical details.

## License

MIT

## Links

- GitHub: [github.com/tpdhd/claude-setup](https://github.com/tpdhd/claude-setup)
- Claude Code: [claude.ai/code](https://claude.ai/code)
