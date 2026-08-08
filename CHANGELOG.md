# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] - 2026-08-08

### Changed
- **Release notes now come from the changelog instead of being generated**: `release.yml` extracts the `## [X.Y.Z]` section from `CHANGELOG.md` and uses it as the release body. Previously the workflow used `generate_release_notes: true`, which lists merged *pull requests* — and this project has never had one, since changes go straight to `main`. The result was that v1.2.0, v1.2.1 and v1.2.2 all published a release body consisting of nothing but a compare link (97 characters for v1.2.2, against 605 characters of curated changelog for the same version). The workflow now fails loudly if no changelog section matches the tag, rather than publishing an empty release.
- **`.shellcheckrc` documents this project**: the file was carried over from an unrelated setup and its header described that setup's machines and script counts. The directives are unchanged (`disable=SC1090,SC1091`, `shell=bash`, `source-path=SCRIPTDIR`, `external-sources=true`, `severity=warning`); only the comments were rewritten, and they now note that CI overrides the severity with `--severity=error`.
- **Issue templates reference the actual library**: the bug report and feature request templates still carried placeholder names (`src/your-library.sh`, `src/new-library.sh`) from a generic Bash toolkit template. The bug report now asks for the reporter's locale, because anchor normalization is locale-sensitive (see 1.2.1), and its reproducer skeleton is a real wrapper.

### Fixed
- **`docs/API_REFERENCE.md` reported version 1.0.1**: the footer had not been updated since 1.0.1 and therefore documented `sed_inplace()`, `skipped_external_urls`, `compute_code_block_lines()` and `strip_inline_code()` under a version that predates all of them. The version is now set in the same release step as the library header.

### Added
- **Community health files**: issue templates (bug report, feature request), an issue template config pointing at Security Advisories and Discussions, and a pull request template.

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
