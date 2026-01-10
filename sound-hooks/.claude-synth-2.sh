#!/usr/bin/env bash
# Synth 2: Upward arpeggio (C6 → E6 → G6)
(play -n synth 0.08 sine 1046.5 vol 0.35 && play -n synth 0.08 sine 1318.5 vol 0.35 && play -n synth 0.12 sine 1568 vol 0.35 fade 0 0.12 0.04) 2>/dev/null &
exit 0
