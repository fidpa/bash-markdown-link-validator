# Bash Markdown Link Validator

**Fast, zero-dependency Markdown link validator with smart anchor resolution. Pure Bash.**

[![GitHub Release](https://img.shields.io/github/v/release/fidpa/bash-markdown-link-validator?include_prereleases&sort=semver)](https://github.com/fidpa/bash-markdown-link-validator/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash 4.0+](https://img.shields.io/badge/bash-4.0%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL2-blue)](https://github.com/fidpa/bash-markdown-link-validator#-platform-support)
[![CI](https://github.com/fidpa/bash-markdown-link-validator/actions/workflows/lint.yml/badge.svg)](https://github.com/fidpa/bash-markdown-link-validator/actions/workflows/lint.yml)
[![ShellCheck](https://img.shields.io/badge/shellcheck-passing-brightgreen)](https://www.shellcheck.net/)
[![Dependencies](https://img.shields.io/badge/dependencies-zero-success)](https://github.com/fidpa/bash-markdown-link-validator#-requirements)
[![Maintenance](https://img.shields.io/badge/maintenance-active-brightgreen)](https://github.com/fidpa/bash-markdown-link-validator/commits/main)
![Last Commit](https://img.shields.io/github/last-commit/fidpa/bash-markdown-link-validator)

---

## ⚡ TL;DR

Checks that every `[text](file.md)` link in a documentation tree points at a file
that exists, and that every `#anchor` matches a real heading. Pure Bash, nothing
to install beyond the shell you already have. It never touches the network:
external URLs are counted and skipped, not fetched. What else it leaves alone is
listed under [What it does not check](#-what-it-does-not-check).

---

## ✨ Features

- **Zero external dependencies** - Bash 4.0+ plus `grep`, `sed` and `find`. No npm, pip or cargo.
- **Anchor resolution beyond exact match** - Lowercasing, umlaut transliteration and GitHub's punctuation rule, then exact match, numbered-section match (`#25-x` finds `#2-5-x`) and suffix match (`#prepared-statements` finds `#2-3-prepared-statements`)
- **Directory links resolve to the landing page** - `[systemd](systemd/)` is checked against `systemd/README.md`, the file GitHub shows for such a link. A directory without one is reported as broken, with `Directory has no README.md` rather than `File not found`
- **Code blocks are skipped** - Links inside fenced blocks and inline code spans are not validated, so a documented example never fails the run
- **Parallel processing** - `-j N`, default 2
- **JSON output** - `--output-format=json` for CI pipelines; quotes, backslashes and control characters in paths are escaped
- **Batch fixing** - `--fix-pattern=OLD:NEW` rewrites matching links in place
- **Wrapper system** - One shared core, one small wrapper script per documentation area

---

## 🚫 What it does not check

The scanner extracts links whose target contains `.md`. Everything outside that
pattern is not validated:

- **External URLs are counted, not fetched.** `http://`, `https://`, `ftp://` and
  `mailto:` links are skipped and reported as "Skipped external URLs". No request
  ever leaves the machine, so a dead web link stays invisible here. A tool that
  does fetch them, lychee for instance, runs alongside this one without conflict.
- **Links whose target is not a Markdown file never reach the validator.**
  `[script](install.sh)` and `[logo](logo.png)` are dropped by `LINK_PATTERN`,
  which admits two shapes: a target containing `.md`, and a directory link
  ending in `/`. This README is its own example: a run over this repository
  counts four links in it, the ones pointing at `docs/`.
- **A missing anchor is a warning, not a failure.** If the file exists but the
  heading does not, the link counts as valid and `exit_with_status()` still
  returns 0. Only a missing *file* produces exit code 1. If CI should fail on
  anchors too, grep the output for "Anchor not found".
- **There is no test suite.** CI runs ShellCheck and `bash -n` on every push;
  everything beyond syntax rests on production use, not on unit tests.

---

## 🚀 Quick Start

### Installation

```bash
git clone https://github.com/fidpa/bash-markdown-link-validator.git
cd bash-markdown-link-validator
./install.sh
```

`install.sh` checks the Bash version and the required tools, then copies
`src/validate-links-core.sh` to `~/.local/lib/bash-markdown-link-validator/` and
writes a `validate-links-sample.sh` next to it to copy and adapt. It refuses to
continue below Bash 4.0. Cloning alone is enough if you would rather point your
wrapper at `src/validate-links-core.sh` in the checkout.

### Basic Usage

Create a wrapper script in your docs directory:

```bash
#!/bin/bash
set -uo pipefail

AREA_NAME="docs"
AREA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCLUDE_DIRS="archive|deprecated"

source "$HOME/.local/lib/bash-markdown-link-validator/validate-links-core.sh" || exit 2

parse_args "$@"
setup_colors
print_validation_header
mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")
[[ $PARALLEL_JOBS -eq 1 ]] && validate_sequential "${md_files[@]}" || validate_parallel "${md_files[@]}"
print_summary_report
exit_with_status
```

`EXCLUDE_DIRS` is a regular expression matched against `/directory/`, so
alternations such as `archive|deprecated|node_modules` work and an empty string
excludes nothing.

### Run It

```bash
./validate-links.sh              # Basic validation
./validate-links.sh -v           # Verbose output
./validate-links.sh -j 4         # 4 parallel jobs
./validate-links.sh --output-format=json  # CI/CD integration
```

---

## 📊 Sample Output

A run with `-j 1` over a directory with one deleted target and one mistyped
anchor:

```
========================================
Link Validation Report - docs
========================================

Scanning: guide/INSTALL.md
Scanning: README.md
  ❌ Line 3: File not found: guide/OLD.md
  ⚠️  Line 5: Anchor not found: #no-such-heading in guide/INSTALL.md
  ✗ 4 links, 1 broken (75% valid)

========================================
Summary
========================================
Total files scanned: 2
Total links found: 4
  Internal links: 4
  External links: 0
Valid links: 3
  Internal valid: 3
  External valid: 0
Broken links: 1
Warnings: 1
Success rate: 75%
========================================
```

The mistyped anchor is the warning; the deleted file is what makes the run exit
with 1. Parallel runs, which is what the default `-j 2` does, print the same
findings but mark the per-file lines `SCANNING:` and `SUMMARY:` instead.

---

## 🎯 Smart Anchor Resolution

Every anchor is normalized before matching: lowercased, umlauts transliterated
(`ä` to `a`, `ß` to `ss`), punctuation removed and spaces turned into hyphens,
which is the rule GitHub itself applies to headings. Three matching strategies
then run in order:

| Pattern | Example | Resolution |
|---------|---------|------------|
| **Exact Match** | `#api-reference` | Matches the normalized heading, so `#API-Reference` finds it too |
| **Numbered Sections** | `#25-troubleshooting` | Matches `#2-5-troubleshooting` |
| **Suffix Match** | `#prepared-statements` | Matches `#2-3-prepared-statements`, that is, a heading carrying a section number |
| **Umlaut Normalization** | `#größe` | Matches `#grosse` |

Suffix matching applies only to anchors without their own section number and
only against headings numbered `N-N-`; it is deliberately narrow, so that
`#setup` does not silently match `#advanced-setup`.

---

## 📈 Comparison

| Tool | Language | Dependencies | Parallel | Anchor matching | External URLs |
|------|----------|--------------|----------|-----------------|---------------|
| **bash-markdown-link-validator** | **Bash** | **None** | ✅ | exact + numbered + suffix | ❌ not checked |
| markdown-link-check | JavaScript | Node.js + npm | ❌ | exact | ✅ checked |
| lychee | Rust | Binary | ✅ | exact | ✅ checked |
| linkchecker | Python | Python + deps | ✅ | exact | ✅ checked |
| remark-validate-links | JavaScript | Node.js + npm | ❌ | exact | ❌ not checked |

The last column is the trade-off, not an oversight: this validator is fast and
dependency-free because it never leaves the filesystem. Entries for the other
tools reflect their documentation as of August 2026; corrections by issue are
welcome.

---

## 🔧 CLI Options

Quoted from `./validate-links.sh --help`:

```
OPTIONS:
    -v, --verbose                Show detailed output for all links
    --no-color                   Disable colored output
    -j N, --parallel-jobs=N      Run N parallel jobs (default: 2)
    --output-format=FORMAT       Output format: text (default) or json
    --fix-pattern=OLD:NEW        Auto-fix links matching OLD pattern to NEW
    --auto-todo                  Mark missing files as TODO (no git history check)
    --no-deep-path-warning       Disable deep path warnings
    --max-path-depth=N           Max ../ levels before warning (default: 5)
    --warm-cache                 Pre-build anchor cache for all files

    -V, --version                Print the library version and exit
    -h, --help                   Show this help message

EXIT CODES:
    0 - All links valid
    1 - Broken links found
    2 - Script error
```

Every option has an environment-variable equivalent (`VERBOSE`, `PARALLEL_JOBS`,
`OUTPUT_FORMAT`, `MAX_PATH_DEPTH` and so on), which is what wrapper scripts set.

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

- **Bash 4.0+** (for associative arrays and `${var,,}` lowercasing)
- **Standard Unix Tools**: `grep`, `sed`, `find`
- **Optional**: `realpath` for tidier relative paths in the report, `git` for the
  history check behind `--auto-todo`

## 🖥️ Platform Support

- ✅ **Linux, WSL2**: Fully supported. CI runs ShellCheck and a syntax check on
  `ubuntu-latest` for every push.
- ✅ **macOS**: Supported since v1.1.0, when the GNU-specific calls (`grep -oP`,
  `sed -i`, `readlink -f`) were replaced by POSIX equivalents. It needs a Bash
  from Homebrew: Apple ships Bash 3.2, which cannot run this code, and
  `install.sh` stops with that message. Not covered by CI, so verified by use
  rather than by a pipeline.
- ❌ **Bash 3.x and other shells**: Not supported. Associative arrays and `${var,,}`
  have no fallback here.

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

Written for a private documentation repository that had grown past the point
where broken links could be found by reading, and used there daily since
August 2025. Public since December 2025.
