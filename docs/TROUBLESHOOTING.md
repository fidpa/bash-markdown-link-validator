# Troubleshooting Guide

## ⚡ TL;DR

Common issues and solutions for bash-markdown-link-validator.

---

## 🔧 Common Issues

### 1. "Cannot load validate-links-core.sh"

**Symptom**:
```
ERROR: Cannot load validate-links-core.sh
```

**Cause**: The library path in your wrapper is incorrect.

**Solution**:
```bash
# Check the path in your wrapper script
source "/path/to/validate-links-core.sh"

# Verify the file exists
ls -la /path/to/validate-links-core.sh

# Use absolute path or resolve relative to script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/validate-links-core.sh"
```

---

### 2. Parallel Mode Hangs

**Symptom**: Script hangs when using `-j N` with N > 1.

**Cause**: Background jobs reading from stdin (TTY issue).

**Solution**: This is fixed in the current version. Ensure you're using the latest release.

The fix includes:
```bash
# In scan_file_parallel()
exec </dev/null  # Disconnect stdin

# Background job spawning
scan_file_parallel "$file" "$output_file" </dev/null &
```

---

### 3. False Positive: Anchor Not Found

**Symptom**:
```
⚠️ Line 42: Anchor not found: #my-section in file.md
```

But the anchor exists in the file.

**Causes & Solutions**:

**a) Case Sensitivity**
```markdown
<!-- File has: -->
# My Section

<!-- Link uses: -->
[Link](#My-Section)  <!-- Wrong: uppercase -->
[Link](#my-section)  <!-- Correct: lowercase -->
```

**b) Special Characters**
```markdown
<!-- File has: -->
# API Reference (v2.0)

<!-- Link uses: -->
[Link](#api-reference-(v2.0))  <!-- Wrong: parentheses -->
[Link](#api-reference-v2-0)    <!-- Correct: normalized -->
```

**c) Umlauts (German characters)**
```markdown
<!-- File has: -->
# Größe und Übersicht

<!-- Link should use: -->
[Link](#grosse-und-ubersicht)  <!-- Umlauts → ASCII -->
```

**Debug**: Check how anchors are normalized:
```bash
# In verbose mode, the library shows anchor resolution
./validate-links.sh -v 2>&1 | grep -i anchor
```

---

### 4. "realpath: command not found"

**Symptom**:
```
realpath: command not found
```

**Cause**: `realpath` is not available on all systems (notably older macOS).

**Solution**: The library has a fallback, but for best results:

```bash
# On macOS with Homebrew
brew install coreutils

# Or use the built-in fallback (automatic)
# The library checks: command -v realpath >/dev/null 2>&1
```

---

### 5. External Links Not Detected

**Symptom**: Links to files outside `AREA_DIR` show as internal.

**Cause**: `AREA_DIR` may not be set correctly.

**Solution**: Verify path setup in your wrapper:
```bash
# Debug: Print paths
echo "AREA_DIR: $AREA_DIR"
echo "DOCS_DIR: $DOCS_DIR"
echo "PROJECT_ROOT: $PROJECT_ROOT"

# Ensure AREA_DIR is an absolute path
readonly AREA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

---

### 6. JSON Output Invalid

**Symptom**: JSON output fails to parse.

**Cause**: Paths containing special characters (", \, newlines) break JSON.

**Solution**: This is a known limitation. For paths with special characters:
```bash
# Use text mode for debugging
./validate-links.sh --output-format=text

# Filter results with jq (if output is mostly valid)
./validate-links.sh --output-format=json 2>/dev/null | jq '.' || echo "JSON parse error"
```

**Note**: JSON escaping is on the roadmap for a future version.

---

### 7. Slow Performance

**Symptom**: Validation takes too long.

**Causes & Solutions**:

**a) Use Parallel Mode**
```bash
# Default is 2 jobs, increase for more CPUs
./validate-links.sh -j 4
./validate-links.sh -j 8
```

**b) Enable Cache Warming**
```bash
# For large documentation with many cross-references
./validate-links.sh --warm-cache
```

**c) Reduce Scope**
```bash
# Exclude directories
EXCLUDE_DIRS="archive|deprecated|drafts"
```

**Performance Reference**:
| Files | Sequential | Parallel (-j 4) |
|-------|------------|-----------------|
| 100 | ~5s | ~2s |
| 500 | ~25s | ~8s |
| 2000 | ~100s | ~30s |

---

### 8. "mapfile: command not found"

**Symptom**:
```
mapfile: command not found
```

**Cause**: Using Bash version < 4.0.

**Solution**:
```bash
# Check version
bash --version

# On macOS, install newer bash
brew install bash

# Add to PATH or call explicitly
/usr/local/bin/bash ./validate-links.sh
```

---

### 9. Colors Not Showing

**Symptom**: Output is monochrome even in terminal.

**Causes & Solutions**:

**a) Not a TTY**
```bash
# Colors are disabled when piping
./validate-links.sh | tee output.log  # No colors

# Force colors (not recommended for logs)
COLOR_OUTPUT=true ./validate-links.sh
```

**b) Terminal Doesn't Support Colors**
```bash
# Check terminal type
echo $TERM

# Most modern terminals support colors
# iTerm2, Terminal.app, gnome-terminal, etc.
```

---

### 10. Batch Fix Not Working

**Symptom**: `--fix-pattern` doesn't replace anything.

**Causes & Solutions**:

**a) Pattern Not Found in Links**
```bash
# Check if pattern exists
grep -r "old-path" docs/

# Pattern must match part of the link path
--fix-pattern="old-path:new-path"
```

**b) Special Characters Not Escaped**
```bash
# Avoid regex special chars in patterns
# The library escapes them, but complex patterns may fail
--fix-pattern="simple-old:simple-new"  # Good
--fix-pattern="path[1]:path[2]"        # May have issues
```

---

## 🐛 Debug Mode

For detailed debugging:

```bash
# Maximum verbosity
./validate-links.sh -v 2>&1 | tee debug.log

# Check specific file
grep "yourfile.md" debug.log

# Trace bash execution (very verbose)
bash -x ./validate-links.sh -v 2>&1 | head -100
```

---

## 📋 Environment Check

Run this to verify your environment:

```bash
#!/bin/bash
echo "=== Environment Check ==="
echo "Bash version: $BASH_VERSION"
echo "realpath: $(command -v realpath 2>/dev/null || echo 'not found')"
echo "grep: $(command -v grep)"
echo "sed: $(command -v sed)"
echo "find: $(command -v find)"
echo "git: $(command -v git 2>/dev/null || echo 'not found (optional)')"
echo ""
echo "Bash >= 4.0: $([ "${BASH_VERSINFO[0]}" -ge 4 ] && echo 'YES ✅' || echo 'NO ❌')"
```

---

## 📚 Getting Help

1. Check the [Quick Start Guide](QUICK_START.md)
2. Review the [API Reference](API_REFERENCE.md)
3. Open an issue on [GitHub](https://github.com/fidpa/bash-markdown-link-validator/issues)

When reporting issues, include:
- Bash version (`bash --version`)
- Operating system
- Full error message
- Minimal reproduction steps
