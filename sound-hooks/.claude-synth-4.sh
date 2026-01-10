#!/usr/bin/env bash
# Synth 4: Single soft beep (800Hz)
play -n synth 0.15 sine 800 vol 0.5 2>/dev/null &
exit 0
