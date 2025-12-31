# Quick Start Guide

## ⚡ TL;DR

Zero-dependency Bash library for Markdown link validation with parallel processing, smart anchor resolution, and JSON output for CI/CD.

## 🎯 Overview

**bash-markdown-link-validator** is a pure Bash solution for validating internal Markdown links. It was developed to solve the problem of broken documentation links in large projects (2,271+ files, 11,000+ links validated daily).

### Key Features

- **Zero External Dependencies** - Pure Bash, no Node.js/Python/Rust required
- **Smart Anchor Resolution** - Suffix-match, umlaut normalization, numbered sections
- **Parallel Processing** - Configurable job count for large documentation sets
- **JSON Output** - CI/CD ready with machine-readable output
- **Production Tested** - 2,271 files validated, 11 active deployments

---

## 🚀 Installation

### Option 1: Clone Repository

```bash
git clone https://github.com/fidpa/bash-markdown-link-validator.git
cd bash-markdown-link-validator
```

### Option 2: Copy Library Only

```bash
# Copy the core library to your project
cp src/validate-links-core.sh /path/to/your/project/scripts/lib/
```

### Option 3: Install Script

```bash
./install.sh
# Installs to ~/.local/lib/bash-markdown-link-validator/
```

---

## 📖 Basic Usage

### Minimal Wrapper Example

Create a wrapper script for your documentation area:

```bash
#!/bin/bash
# validate-links.sh - Place in your docs directory
set -uo pipefail

# Configuration
AREA_NAME="docs"
AREA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
EXCLUDE_DIRS="archive|deprecated"

# Source the library
source "/path/to/validate-links-core.sh" || exit 2

# Run validation
parse_args "$@"
setup_colors
print_validation_header
mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")

if [[ $PARALLEL_JOBS -eq 1 ]]; then
    validate_sequential "${md_files[@]}"
else
    validate_parallel "${md_files[@]}"
fi

print_summary_report
exit_with_status
```

### Run the Validation

```bash
# Basic validation (2 parallel jobs by default)
./validate-links.sh

# Verbose output
./validate-links.sh -v

# 4 parallel jobs
./validate-links.sh -j 4

# Sequential mode
./validate-links.sh -j 1

# Disable colors (for logs/CI)
./validate-links.sh --no-color
```

---

## 📊 Sample Output

```
========================================
Link Validation Report - docs
========================================

Scanning: getting-started/INSTALLATION.md
  ✓ 12 links, all valid (100%)

Scanning: reference/API.md
  ❌ Line 45: File not found: ../how-to/DEPRECATED.md
  ✗ 8 links, 1 broken (87% valid)

Scanning: how-to/DEPLOYMENT.md
  ⚠️  Line 23: Anchor not found: #configuration in ../reference/CONFIG.md
  ✓ 15 links, all valid (100%)

========================================
Summary
========================================
Total files scanned: 127
Total links found: 892
  Internal links: 845
  External links: 47
Valid links: 891
Broken links: 1
Warnings: 1
Success rate: 99%
========================================
```

---

## 🔧 CLI Options

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Show detailed output for all links |
| `--no-color` | Disable colored output |
| `-j N, --parallel-jobs=N` | Run N parallel jobs (default: 2) |
| `--output-format=FORMAT` | Output format: text (default) or json |
| `--fix-pattern=OLD:NEW` | Auto-fix links matching OLD pattern to NEW |
| `--auto-todo` | Mark missing files as TODO |
| `--no-deep-path-warning` | Disable deep path warnings |
| `--max-path-depth=N` | Max ../ levels before warning (default: 5) |
| `--warm-cache` | Pre-build anchor cache for all files |
| `-h, --help` | Show help message |

---

## 🎯 Exit Codes

| Code | Meaning |
|------|---------|
| 0 | All links valid |
| 1 | Broken links found |
| 2 | Script error |

---

## 📚 Next Steps

- [API Reference](API_REFERENCE.md) - Full function documentation
- [Wrapper System](WRAPPER_SYSTEM.md) - Multi-area validation pattern
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions

---

## 🔗 Requirements

- **Bash 4.0+** (for associative arrays, `${var,,}` lowercase)
- **Standard Unix Tools**: `grep`, `sed`, `find`, `realpath`
- **Optional**: `git` (for auto-TODO feature)

Works on: Linux, macOS, WSL2, any POSIX-compliant system with Bash 4.0+
