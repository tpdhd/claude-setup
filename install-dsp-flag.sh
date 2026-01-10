#!/bin/bash

# Permanent --dsp Flag Installer for Claude Code
# This script creates a wrapper that adds the --dsp flag to Claude
# The wrapper survives all npm updates permanently

set -e  # Exit on error

echo "========================================="
echo "Claude Code --dsp Flag Installer"
echo "========================================="
echo ""
echo "This script will install a permanent --dsp flag for Claude."
echo "The flag will work exactly like --dangerously-skip-permissions"
echo "and will survive all npm updates."
echo ""

# Check if Claude is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude Code is not installed or not in PATH"
    echo "   Please install Claude Code first: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

echo "✓ Claude Code found at: $(which claude)"
echo ""

# Step 1: Create directory
echo "[1/5] Creating ~/.local/bin directory..."
mkdir -p ~/.local/bin
echo "✓ Directory created"
echo ""

# Step 2: Create wrapper script
echo "[2/5] Creating wrapper script..."
cat > ~/.local/bin/claude << 'EOF'
#!/bin/bash

# Permanent wrapper script for Claude that adds support for --dsp flag
# This survives npm updates to Claude Code by intercepting calls before the real binary

# The real Claude binary location (npm global installation)
REAL_CLAUDE="$(readlink -f "$(which -a claude | grep -v "^$HOME/.local/bin" | head -1)" 2>/dev/null)"

# Fallback: Try common npm global locations
if [[ ! -f "$REAL_CLAUDE" ]]; then
    for path in \
        "$HOME/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "$HOME/.nvm/versions/node/*/lib/node_modules/@anthropic-ai/claude-code/cli.js" \
        "/opt/homebrew/lib/node_modules/@anthropic-ai/claude-code/cli.js"; do
        if [[ -f "$path" ]]; then
            REAL_CLAUDE="$path"
            break
        fi
    done
fi

# Check if we found Claude
if [[ ! -f "$REAL_CLAUDE" ]]; then
    echo "Error: Cannot find real Claude binary" >&2
    echo "Looked in: npm global directories" >&2
    exit 1
fi

# Process arguments to replace --dsp with --dangerously-skip-permissions
args=()
for arg in "$@"; do
    if [[ "$arg" == "--dsp" ]]; then
        args+=("--dangerously-skip-permissions")
    else
        args+=("$arg")
    fi
done

# Call the real Claude with modified arguments
exec "$REAL_CLAUDE" "${args[@]}"
EOF

echo "✓ Wrapper script created at ~/.local/bin/claude"
echo ""

# Step 3: Make executable
echo "[3/5] Making wrapper executable..."
chmod +x ~/.local/bin/claude
echo "✓ Wrapper is now executable"
echo ""

# Step 4: Update PATH
echo "[4/5] Updating PATH configuration..."

# Detect shell
SHELL_CONFIG=""
if [[ -f ~/.bashrc ]]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [[ -f ~/.zshrc ]]; then
    SHELL_CONFIG="$HOME/.zshrc"
else
    echo "⚠️  Warning: Could not find ~/.bashrc or ~/.zshrc"
    echo "   You'll need to manually add this line to your shell config:"
    echo '   export PATH="$HOME/.local/bin:$PATH"'
    SHELL_CONFIG=""
fi

if [[ -n "$SHELL_CONFIG" ]]; then
    # Check if .local/bin is already in PATH config
    if grep -q '$HOME/.local/bin' "$SHELL_CONFIG" 2>/dev/null || grep -q '~/.local/bin' "$SHELL_CONFIG" 2>/dev/null; then
        echo "✓ ~/.local/bin already in PATH configuration"
    else
        # Add to shell config
        echo "" >> "$SHELL_CONFIG"
        echo "# Add ~/.local/bin to PATH (for Claude --dsp wrapper)" >> "$SHELL_CONFIG"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
        echo "✓ Added ~/.local/bin to PATH in $SHELL_CONFIG"
    fi
fi
echo ""

# Step 5: Test installation
echo "[5/5] Testing installation..."

# Export PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Test which claude is found
FOUND_CLAUDE=$(which claude)
if [[ "$FOUND_CLAUDE" == "$HOME/.local/bin/claude" ]]; then
    echo "✓ Wrapper is correctly found in PATH"
else
    echo "⚠️  Warning: Wrapper not found first in PATH"
    echo "   Current: $FOUND_CLAUDE"
    echo "   Expected: $HOME/.local/bin/claude"
    echo "   You may need to open a new terminal for changes to take effect"
fi

# Test --dsp flag
echo ""
echo "Testing --dsp flag..."
if echo "test" | timeout 10 claude --dsp -p "Say: OK" 2>&1 | grep -q "OK"; then
    echo "✓ --dsp flag is working!"
else
    echo "⚠️  Could not verify --dsp flag functionality"
    echo "   This may be normal - please test manually after installation"
fi

echo ""
echo "========================================="
echo "Installation Complete!"
echo "========================================="
echo ""
echo "The --dsp flag has been installed successfully."
echo ""
echo "IMPORTANT: To use the flag in your CURRENT terminal session, run:"
echo "  source ~/.bashrc    (or ~/.zshrc if using Zsh)"
echo ""
echo "Or simply open a NEW terminal."
echo ""
echo "Usage:"
echo "  claude --dsp                    # Use dangerously skip permissions mode"
echo "  claude --dsp -p \"your prompt\"   # Non-interactive mode"
echo ""
echo "This wrapper will survive all npm updates permanently."
echo ""
echo "To verify installation in a new shell:"
echo "  which claude    # Should show: $HOME/.local/bin/claude"
echo '  echo "test" | claude --dsp -p "Say: DSP working!"'
echo ""
echo "To uninstall:"
echo "  rm ~/.local/bin/claude"
echo ""
