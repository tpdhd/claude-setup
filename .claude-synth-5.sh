#!/usr/bin/env bash
# Synth 5: Double ascending beep (600Hz → 900Hz)
(play -n synth 0.1 sine 600 vol 0.5 && play -n synth 0.12 sine 900 vol 0.45) 2>/dev/null &
exit 0
