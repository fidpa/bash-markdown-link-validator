# bash-markdown-link-validator

**Fast, zero-dependency Markdown link validator with smart anchor resolution. Pure Bash.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash 4.0+](https://img.shields.io/badge/bash-4.0%2B-green.svg)](https://www.gnu.org/software/bash/)

---

## ⚡ TL;DR

Validates 2,271 Markdown files with zero Node/Python/Rust dependencies. Pure Bash, 11 active deployments, production-tested for 5+ months.

---

## ✨ Features

- **Zero External Dependencies** - Pure Bash, no npm/pip/cargo installs required
- **Smart Anchor Resolution** - Suffix-match, umlaut normalization, numbered sections
- **Parallel Processing** - Configurable job count for large documentation sets
- **JSON Output** - CI/CD ready with machine-readable output
- **Wrapper System** - Multi-area validation with DRY principle
- **AI-Agent Ready** - Designed for Claude Code, Cursor, GitHub Copilot workflows
- **Production Tested** - 2,271 files, 11,000+ links validated daily

---

## 🚀 Quick Start

### Installation

```bash
git clone https://github.com/fidpa/bash-markdown-link-validator.git
cd bash-markdown-link-validator
```

### Basic Usage

Create a wrapper script in your docs directory:

```bash
#!/bin/bash
set -uo pipefail

AREA_NAME="docs"
AREA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
EXCLUDE_DIRS="archive|deprecated"

source "/path/to/validate-links-core.sh" || exit 2

parse_args "$@"
setup_colors
mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")
[[ $PARALLEL_JOBS -eq 1 ]] && validate_sequential "${md_files[@]}" || validate_parallel "${md_files[@]}"
print_summary_report
exit_with_status
```

### Run It

```bash
./validate-links.sh              # Basic validation
./validate-links.sh -v           # Verbose output
./validate-links.sh -j 4         # 4 parallel jobs
./validate-links.sh --output-format=json  # CI/CD integration
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

========================================
Summary
========================================
Total files scanned: 127
Total links found: 892
Valid links: 891
Broken links: 1
Success rate: 99%
========================================
```

---

## 🎯 Smart Anchor Resolution

Unlike other tools that only do exact matching, this validator handles:

| Pattern | Example | Resolution |
|---------|---------|------------|
| **Suffix Match** | `#prepared-statements` | Matches `#2-3-prepared-statements` |
| **Umlaut Normalization** | `#größe` | Matches `#grosse` |
| **Numbered Sections** | `#25-troubleshooting` | Matches `#2-5-troubleshooting` |
| **Case Insensitive** | `#API-Reference` | Matches `#api-reference` |

---

## 📈 Comparison

| Tool | Language | Dependencies | Parallel | Anchor Modes |
|------|----------|--------------|----------|--------------|
| **bash-markdown-link-validator** | **Bash** | **None** | ✅ | **4 (smart)** |
| markdown-link-check | JavaScript | Node.js + npm | ❌ | 1 (exact) |
| lychee | Rust | Binary | ✅ | ❌ |
| linkchecker | Python | Python + deps | ✅ | 1 (exact) |
| remark-validate-links | JavaScript | Node.js + npm | ❌ | 1 (exact) |

---

## 🔧 CLI Options

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Show detailed output for all links |
| `--no-color` | Disable colored output |
| `-j N, --parallel-jobs=N` | Run N parallel jobs (default: 2) |
| `--output-format=json` | JSON output for CI/CD |
| `--fix-pattern=OLD:NEW` | Batch-fix links matching pattern |
| `--auto-todo` | Mark missing files as TODO |
| `--warm-cache` | Pre-build anchor cache |

---

## 📚 Documentation

- [Quick Start Guide](docs/QUICK_START.md) - Installation and basic usage
- [API Reference](docs/API_REFERENCE.md) - Full function documentation
- [Wrapper System](docs/WRAPPER_SYSTEM.md) - Multi-area validation pattern
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

---

## 📁 Examples

| Example | Use Case |
|---------|----------|
| [basic-wrapper.sh](examples/basic-wrapper.sh) | Single directory (e.g., `docs/`) |
| [multi-area-wrapper.sh](examples/multi-area-wrapper.sh) | Multiple areas (e.g., DIATAXIS: tutorial, how-to, reference, explanation) |

---

## 🔗 Requirements

- **Bash 4.0+** (for associative arrays)
- **Standard Unix Tools**: `grep`, `sed`, `find`
- **Optional**: `realpath`, `git`

Works on: Linux, macOS, WSL2, any POSIX-compliant system

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

Built with lessons learned from validating 2,271 Markdown files across 11 documentation areas. Production-tested since July 2025.
