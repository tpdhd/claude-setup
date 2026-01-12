# New Notification System Implementation Guide

## Overview

This guide documents the implementation of a custom notification sound system for Claude Code using the awesome-claude-code hooks with a custom C7 ping tone. This approach combines the robustness of the awesome-claude-code hook system with a shorter, less annoying notification sound.

## System Information

**Environment**: Ubuntu (userland)
**Audio System**: PulseAudio (paplay utility)
**Sound Generation Tool**: SoX (Sound eXchange)

## Implementation Steps

### 1. Install awesome-claude-code Hooks

First, clone and install the awesome-claude-code repository which provides notification hooks for Claude Code:

```bash
# Clone the repository
git clone https://github.com/pascalporedda/awesome-claude-code.git
cd awesome-claude-code

# Run the global installer (select option 1 for sound notifications)
echo "1" | ./install-global.sh
```

This will:
- Create `~/.claude/hooks/` directory with TypeScript hook files
- Create `~/.claude/logs/` for event logging
- Copy default .wav notification sounds to `~/.claude/`
- Update `~/.claude/settings.json` with hook configurations

### 2. Install SoX Audio Tool

SoX is required to generate custom notification sounds:

```bash
sudo apt-get update
sudo apt-get install -y sox
```

Verify installation:
```bash
sox --version
```

### 3. Generate Custom C7 Ping Sound

We chose a **C7 high-pitched ping** (2093Hz, 0.08 seconds) as the optimal notification sound - short, distinctive, and non-intrusive.

**Sound Specifications**:
- **Frequency**: 2093 Hz (C7 musical note)
- **Duration**: 0.08 seconds
- **Fade**: 0.02 second fade-out
- **Waveform**: Pure sine wave

Generate the sound:

```bash
# Create temporary directory for sound generation
mkdir -p /tmp/notification-sounds
cd /tmp/notification-sounds

# Generate C7 ping (2093Hz, 0.08 seconds)
sox -n option-c7.wav synth 0.08 sine 2093 fade 0 0.08 0.02
```

Test the sound:
```bash
paplay option-c7.wav
```

### 4. Replace Default Notification Sounds

Copy the custom C7 ping to replace both notification sounds:

```bash
# Replace "need attention" sound
cp /tmp/notification-sounds/option-c7.wav ~/.claude/on-agent-need-attention.wav

# Replace "complete" sound
cp /tmp/notification-sounds/option-c7.wav ~/.claude/on-agent-complete.wav
```

Verify the installation:
```bash
ls -lh ~/.claude/*.wav
```

You should see two ~16KB files (much smaller than the original 234KB and 493KB files).

### 5. Hook Configuration

The hooks are already configured by the awesome-claude-code installer. Verify your `~/.claude/settings.json` contains:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx /home/userland/.claude/hooks/notification.ts --notify"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx /home/userland/.claude/hooks/stop.ts --chat"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "npx tsx /home/userland/.claude/hooks/subagent_stop.ts"
          }
        ]
      }
    ]
  }
}
```

## Why This Tone?

The C7 ping was selected after testing multiple options:

**Tested Alternatives**:
1. Single short high-pitched beep (800Hz + 1600Hz octave)
2. Double beep (1000Hz)
3. Triple ascending tones (600→800→1000Hz)
4. Low gentle beep (440Hz, 0.25s)
5. Two-tone chime (880→660Hz)
6. Lower single beep (330Hz, 0.2s)

**C7 Selected Because**:
- Very short duration (0.08s) - doesn't interrupt workflow
- High frequency (2093Hz) - cuts through ambient noise without being harsh
- Simple pure sine wave - clean and professional
- Small file size (~16KB) - efficient
- Matches the existing `.claude-synth-3.sh` standard in this repository

## Audio Playback Details

**Linux/Ubuntu**: Uses `paplay` (PulseAudio utility)
```bash
paplay /path/to/sound.wav
```

**Alternative Players**:
- `aplay` (ALSA)
- `play` (SoX)

## Event Logging

The hooks automatically log events to `~/.claude/logs/`:
- `notifications.json` - When Claude needs attention
- `stop.json` - When Claude completes tasks
- `subagent_stop.json` - When subagents complete
- `chat.json` - Full conversation transcripts (if enabled)

## Verification

Test the notification system:

```bash
# Test the need-attention sound
paplay ~/.claude/on-agent-need-attention.wav

# Test the completion sound
paplay ~/.claude/on-agent-complete.wav

# Check hook files exist
ls -la ~/.claude/hooks/

# Verify logs directory
ls -la ~/.claude/logs/
```

## Troubleshooting

### No Sound Output

1. Check audio system:
```bash
paplay --help
echo "$PULSE_SERVER"
```

2. Verify sound files exist:
```bash
ls -lh ~/.claude/*.wav
```

3. Test with system beep:
```bash
paplay /usr/share/sounds/alsa/Front_Center.wav
```

### Hooks Not Triggering

1. Check Node.js/npx availability:
```bash
node --version
npx --version
```

2. Verify settings.json configuration
3. Check logs for errors:
```bash
cat ~/.claude/logs/notifications.json
```

## Alternative Tones (Quick Reference)

If you want to try different tones, use these sox commands:

```bash
# Higher pitch, shorter (C8 - 4186Hz)
sox -n sound.wav synth 0.05 sine 4186 fade 0 0.05 0.02

# Lower pitch, gentle (A4 - 440Hz)
sox -n sound.wav synth 0.15 sine 440 fade 0 0.15 0.05

# Double beep
sox -n b1.wav synth 0.1 sine 1000 fade 0 0.1 0.03
sox -n b2.wav synth 0.1 sine 1000 fade 0 0.1 0.03
sox b1.wav -p pad 0 0.08 | sox - b2.wav double-beep.wav
```

## System Requirements

- **OS**: Ubuntu/Linux with PulseAudio
- **Node.js**: v20+ (for running TypeScript hooks)
- **npx**: 10+ (included with Node.js)
- **SoX**: 14.4+ (for sound generation)
- **paplay**: PulseAudio utils (for playback)

## Benefits Over Default Sounds

1. **Shorter**: 0.08s vs 1-2s default sounds
2. **Smaller**: 16KB vs 234-493KB files
3. **Less Intrusive**: Quick ping doesn't disrupt focus
4. **Customizable**: Easy to regenerate with different parameters
5. **Professional**: Clean sine wave, no harsh noise

## File Sizes Comparison

| File | Original | Custom C7 |
|------|----------|-----------|
| on-agent-need-attention.wav | 234 KB | 16 KB |
| on-agent-complete.wav | 493 KB | 16 KB |
| **Total** | **727 KB** | **32 KB** |

## Quick AI Implementation Checklist

For an AI to implement this system:

1. ✅ Clone awesome-claude-code repository
2. ✅ Run global installer (select option 1)
3. ✅ Install sox package
4. ✅ Generate C7 ping: `sox -n sound.wav synth 0.08 sine 2093 fade 0 0.08 0.02`
5. ✅ Copy to both notification files in ~/.claude/
6. ✅ Verify with `paplay` test
7. ✅ Check hooks are in ~/.claude/hooks/
8. ✅ Confirm settings.json is updated

## References

- **awesome-claude-code**: https://github.com/pascalporedda/awesome-claude-code
- **SoX Documentation**: http://sox.sourceforge.net/
- **Musical Note Frequencies**: C7 = 2093.00 Hz
- **Related File**: `sound-hooks/.claude-synth-3.sh` (same tone using `play` command)

## Credits

Implementation developed through collaborative session with Claude Code AI on Ubuntu userland environment (2026-01-12).
