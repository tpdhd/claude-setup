#!/bin/bash

# Verification script for --dsp flag installation
# Run this to verify that the --dsp flag is working correctly

echo "========================================="
echo "DSP Flag Verification"
echo "========================================="
echo ""

# Check if wrapper exists
if [[ -f ~/.local/bin/claude ]]; then
    echo "✓ Wrapper script exists at ~/.local/bin/claude"
else
    echo "✗ Wrapper script NOT found at ~/.local/bin/claude"
    exit 1
fi

# Check if wrapper is executable
if [[ -x ~/.local/bin/claude ]]; then
    echo "✓ Wrapper script is executable"
else
    echo "✗ Wrapper script is not executable"
    exit 1
fi

# Check which Claude is found
FOUND_CLAUDE=$(which claude)
if [[ "$FOUND_CLAUDE" == "$HOME/.local/bin/claude" ]]; then
    echo "✓ Wrapper is found first in PATH: $FOUND_CLAUDE"
else
    echo "⚠ Warning: Wrapper not found first"
    echo "  Found: $FOUND_CLAUDE"
    echo "  Expected: $HOME/.local/bin/claude"
    echo ""
    echo "  This is normal if you haven't opened a new terminal yet."
    echo "  Run: source ~/.bashrc"
fi

echo ""
echo "Testing --dsp flag..."
if echo "test" | timeout 5 claude --dsp -p "Say: OK" 2>&1 | grep -q "OK"; then
    echo "✓ --dsp flag is working!"
else
    echo "✗ --dsp flag test failed"
    exit 1
fi

echo ""
echo "Testing original --dangerously-skip-permissions flag..."
if echo "test" | timeout 5 claude --dangerously-skip-permissions -p "Say: OK" 2>&1 | grep -q "OK"; then
    echo "✓ Original flag still works!"
else
    echo "✗ Original flag test failed"
    exit 1
fi

echo ""
echo "========================================="
echo "All checks passed!"
echo "========================================="
echo ""
echo "You can now use: claude --dsp"
echo "This will persist across all npm updates."
