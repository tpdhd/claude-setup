#!/data/data/com.termux/files/usr/bin/bash
# Synth 6: Soft bell-like tone (D6 → F#6)
(play -n synth 0.15 sine 1174.7 vol 0.35 fade 0 0.15 0.05 && play -n synth 0.2 sine 1480 vol 0.3 fade 0 0.2 0.08) 2>/dev/null &
exit 0
