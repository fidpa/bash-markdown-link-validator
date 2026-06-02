# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2026-06-02

### Fixed
- **False-positive broken links inside code blocks**: Links inside fenced code blocks and inline-code spans are no longer validated. Previously every Markdown link was checked even inside code examples, producing false-positive "file not found" errors in documentation that *shows* example links (README templates, link-style guides, documentation-about-documentation). Fenced detection follows CommonMark variable-length fence rules, so a 4-backtick example block may contain literal 3-backtick blocks without closing prematurely. Adds `compute_code_block_lines()` and `strip_inline_code()`.

## [1.2.1] - 2026-06-01

### Fixed
- **Uppercase umlaut anchors under non-UTF-8 locales**: `normalize_anchor()` now transliterates `Ä/Ö/Ü/ẞ` to ASCII *before* the lowercase step. Previously, `${var,,}` only lowercased uppercase umlauts in UTF-8 locales; under `LC_ALL=C` they survived, missed the lowercase transliterations, and were stripped by the `[^a-z0-9]` filter (e.g. a heading "Übersicht" produced the anchor `bersicht`). This caused false-positive "anchor not found" warnings for headings starting with an uppercase umlaut on systems with a non-UTF-8 locale.

## [1.2.0] - 2026-01-21

### Added
- **CI/CD Pipeline**: GitHub Actions workflows for automated testing and releases
  - `lint.yml`: ShellCheck validation + Bash syntax check on every push/PR
  - `release.yml`: Automatic GitHub Releases when tagging with `v*`
- **ShellCheck Configuration**: `.shellcheckrc` with Best Practices 2025 settings
- **Community Files**: CONTRIBUTING.md, SECURITY.md, CODE_OF_CONDUCT.md
- **Documentation**: docs/README.md navigation hub for better discoverability
- **README Badge**: CI status badge showing workflow results

### Changed
- **README**: Expanded badges from 2 to 8 (added Release, Platform, CI, ShellCheck, Dependencies, Maintenance)

## [1.1.0] - 2026-01-17

### Added
- **macOS compatibility**: Full POSIX-compliant implementation
- **`skipped_external_urls` counter**: Separate tracking for http/https/ftp/mailto links
- **Platform detection**: Automatic GNU/BSD sed detection via `sed_inplace()` helper
- **JSON-only output mode**: Strict JSON output without scan/error lines (fixes CI/CD parsing)

### Fixed
- **External URL counting**: External URLs (http/https/ftp/mailto) are now properly categorized as "skipped" instead of being counted as "internal valid"
- **Multi-link per line**: Non-greedy regex (`\[[^]]*\]`) now correctly handles multiple links on the same line
- **Explicit ID anchors**: `id="..."` attributes are now normalized consistently with header anchors
- **macOS compatibility**:
  - Replaced `grep -oP` (GNU-only) with POSIX-compatible `sed` patterns
  - Replaced `sed -i` with platform-aware `sed_inplace()` function
  - Replaced `readlink -f` with `pwd -P` in examples
- **JSON output guards**: All verbose/scan output is now suppressed in JSON mode

### Changed
- **Platform support**: Updated README with accurate platform compatibility
  - ✅ Linux: Full support (GNU tools)
  - ✅ macOS: Full support (POSIX-compatible since v1.1.0)
  - ✅ WSL2: Full support
  - ⚠️ Generic POSIX: Partial (requires Bash 4.0+)
- **Examples**: Updated `basic-wrapper.sh` and `multi-area-wrapper.sh` with POSIX-compatible path resolution

### Technical Details
- **Lines changed**: ~162 lines across 4 files
- **Files modified**: `src/validate-links-core.sh`, `examples/basic-wrapper.sh`, `examples/multi-area-wrapper.sh`, `README.md`
- **Backward compatibility**: ✅ All existing features remain functional

## [1.0.1] - 2025-12-31

### Fixed
- Initial bug fixes and improvements

## [1.0.0] - 2025-12-31

### Added
- Initial release
- Smart anchor resolution (suffix-match, umlaut normalization, numbered sections)
- Parallel processing with configurable job count
- JSON output for CI/CD integration
- Batch-fix mode for link pattern replacement
- Deep path warnings and auto-TODO marking
- Wrapper system for easy integration

---

**Repository**: https://github.com/fidpa/bash-markdown-link-validator
**License**: MIT
