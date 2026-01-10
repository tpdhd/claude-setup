# Claude Code Commands Reference

## Quick Reference

### Standard Commands

```bash
claude                                       # Start interactive mode
claude --dsp                                # Start with --dsp flag (requires setup - see DSP-FLAG-GUIDE.md)
claude --dangerously-skip-permissions       # Start without permission prompts
claude --version                            # Show version
claude --help                               # Show help
```

**Note:** The `--dsp` flag is a custom shorthand for `--dangerously-skip-permissions`. See [DSP-FLAG-GUIDE.md](./DSP-FLAG-GUIDE.md) for complete setup instructions.

### Non-Interactive Mode

```bash
echo "input" | claude -p "your prompt"                           # Basic usage
echo "input" | claude --dsp -p "your prompt"                     # With --dsp flag (if configured)
cat file.txt | claude -p "summarize this"                        # Process file content
claude -p "create a hello world script" > script.sh              # Save output to file
```

---

## Additional Custom Shortcuts (Optional)

You can create standalone command aliases if you want shortcuts that aren't flag expansions:

### Bash/Zsh Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Standalone shortcuts (different from --dsp flag expansion)
alias c='claude --dangerously-skip-permissions'         # Quick start
alias cdsp='claude --dangerously-skip-permissions'      # Alternative shortcut
```

**Note:** These create new commands (`c`, `cdsp`), not flag expansions. They work differently than the `--dsp` flag method.

**Comparison:**
```bash
# With bash function method (expands --dsp flag)
claude --dsp -p "hello"                    # Works
some-script.sh | claude --dsp              # Works

# With alias method (creates new command)
c -p "hello"                               # Works
cdsp -p "hello"                            # Works
claude --dsp -p "hello"                    # Doesn't work (--dsp not recognized)
```

Choose based on your preference:
- **Bash function method:** Adds `--dsp` as a real flag to `claude` command
- **Alias method:** Creates new shortcut commands

---

## Git Commands Integration

After making changes with Claude:

```bash
git status                          # Check what changed
git diff                            # See detailed changes
git add .                           # Stage all changes
git commit -m "description"         # Commit changes
git push                            # Push to remote
```

For commits:
```bash
# Let Claude help with commit messages
git diff | claude --dsp -p "write a concise commit message for these changes"
```

---

## Useful Patterns

### Process Multiple Files

```bash
for file in *.txt; do
    claude --dsp -p "summarize $file" < "$file" > "${file%.txt}_summary.txt"
done
```

### Chain Commands

```bash
echo "write a Python function to calculate fibonacci" | \
  claude --dsp -p "generate code" | \
  tee fib.py | \
  python3
```

### Interactive Script

```bash
#!/bin/bash
read -p "Enter your question: " question
echo "$question" | claude --dsp -p "answer concisely"
```

---

## Account Switching (if configured)

If you have multiple Claude accounts set up:

```bash
ca1    # Switch to account 1
ca2    # Switch to account 2
```

See [GIT-CONFIGURATION-GUIDE.md](./GIT-CONFIGURATION-GUIDE.md) for account switching configuration.

---

## Common Issues

### "claude: command not found"

**Problem:** Claude Code not installed or not in PATH

**Solution:**
```bash
npm install -g @anthropic-ai/claude-code
# or
npm update -g @anthropic-ai/claude-code
```

### "--dsp: unknown option"

**Problem:** The --dsp flag hasn't been configured

**Solution:** Follow setup in [DSP-FLAG-GUIDE.md](./DSP-FLAG-GUIDE.md)

### Permission errors

**Problem:** Claude asking for permissions repeatedly

**Solution:** Use `--dangerously-skip-permissions` or configure `--dsp` flag

---

## Summary

- **Built-in flags:** `--dangerously-skip-permissions`, `--version`, `--help`
- **Custom flag:** `--dsp` (requires setup, see DSP-FLAG-GUIDE.md)
- **Custom aliases:** Create your own shortcuts as needed
- **Chaining:** Claude works great with Unix pipes and redirects

**Remember:** Only use `--dangerously-skip-permissions` mode in safe, sandboxed environments.
