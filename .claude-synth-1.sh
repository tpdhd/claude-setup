#!/data/data/com.termux/files/usr/bin/bash
# Synth 1: Gentle two-note chime (E6 → A6)
(play -n synth 0.12 sine 1318.5 vol 0.4 fade 0 0.12 0.03 && play -n synth 0.15 sine 1760 vol 0.35 fade 0 0.15 0.05) 2>/dev/null &
exit 0
