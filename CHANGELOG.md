# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.4] - 2026-08-28: Every release page carries a headline and the changelog section it belongs to

### Changed
- **Release titles now say what a version changes**: `release.yml` reads the headline from the changelog heading (`## [X.Y.Z] - YYYY-MM-DD: <headline>`) and passes it to `softprops/action-gh-release` as `name:`. Without that input the action falls back to the tag name, which is why v1.2.0 through v1.2.3 were all titled after their own version number, a value the release list already shows next to them. The workflow logs a warning when a heading carries no headline instead of falling back silently.
- **Release bodies match their changelog section byte for byte**: the extraction step now strips the leading blank line (`sed -e '/./,$!d'`). The published v1.2.3 body began with one because the `awk` output starts after the heading line, so every byte-exact comparison against `CHANGELOG.md` reported a difference that was not one.
- **The extraction stops at any `##` heading**, not only at the next `## [`. The repository and license lines at the end of the file now sit under a `## Links` heading, so the oldest section ends where it should instead of carrying them into its release body.
- **The older sections were checked against the tags they describe** and corrected where the code contradicted them; every measured value, path and function name that held up is unchanged. The corrections are listed in the sections below. The uppercase umlauts in the [1.2.1] section are quotations of the characters the entry is about and stay as they are.

## [1.2.3] - 2026-08-08: Release bodies carry the curated changelog instead of an empty compare link

### Changed
- **Release notes now come from the changelog instead of being generated**: `release.yml` extracts the `## [X.Y.Z]` section from `CHANGELOG.md` and uses it as the release body. Previously the workflow used `generate_release_notes: true`, which lists merged *pull requests*, and this project has never had one, since changes go straight to `main`. The result was that v1.2.0, v1.2.1 and v1.2.2 all published a release body consisting of nothing but a compare link (97 characters for v1.2.2, against 604 characters of curated changelog for the same version). The workflow now fails loudly if no changelog section matches the tag, rather than publishing an empty release.
- **`.shellcheckrc` describes this project instead of an unrelated one**: the file was carried over from another setup and its header named that setup's machines and script counts. The directives are unchanged (`disable=SC1090,SC1091`, `shell=bash`, `source-path=SCRIPTDIR`, `external-sources=true`, `severity=warning`); only the comments were rewritten, and they now note that CI overrides the severity with `--severity=error`.
- **Bug reports arrive with the information that decides the answer**: the issue templates still carried placeholder names (`src/your-library.sh`, `src/new-library.sh`) from a generic Bash toolkit template. The bug report now asks for the reporter's locale, because anchor normalization is locale-sensitive (see 1.2.1), and its reproducer skeleton is a real wrapper.

### Fixed
- **The API reference no longer documents functions under a version that predates them**: the footer of `docs/API_REFERENCE.md` had not been touched since 1.0.1 and therefore listed `sed_inplace()`, `skipped_external_urls`, `compute_code_block_lines()` and `strip_inline_code()` under that number. The footer is now set in the same release step as the library header in `src/validate-links-core.sh`.

### Added
- **Community health files**: issue templates (bug report, feature request), an issue template config pointing at Security Advisories and Discussions, and a pull request template.

## [1.2.2] - 2026-06-02: Example links in documentation stop failing the check

### Fixed
- **Documentation that shows example links passes the check**: links inside fenced code blocks and inline-code spans are no longer validated. Previously every Markdown link was checked even inside code examples, producing "file not found" errors for paths that were never meant to resolve, which is the normal case in README templates, link-style guides and documentation about documentation. Fenced detection follows the CommonMark variable-length fence rule, so a 4-backtick example block may contain literal 3-backtick blocks without closing prematurely. Adds `compute_code_block_lines()` and `strip_inline_code()`.

## [1.2.1] - 2026-06-01: Headings starting with an uppercase umlaut resolve under any locale

### Fixed
- **Anchors for headings that start with an uppercase umlaut resolve under a non-UTF-8 locale**: `normalize_anchor()` transliterates `Ä/Ö/Ü/ẞ` to ASCII *before* the lowercase step. Previously `${var,,}` only lowercased uppercase umlauts in UTF-8 locales; under `LC_ALL=C` they survived, missed the lowercase transliterations, and were stripped by the `[^a-z0-9]` filter, so the heading "Übersicht" produced the anchor `bersicht` and the link to it was reported as "anchor not found".

## [1.2.0] - 2026-01-21: Every push is linted and every tag publishes a release

### Added
- **Every push and pull request is checked before it lands**: `.github/workflows/lint.yml` runs ShellCheck and a `bash -n` syntax check over `src/`, `examples/` and `install.sh`.
- **Tagging a version publishes it**: `.github/workflows/release.yml` creates a GitHub Release on every `v*` tag.
- **The lint gate is configured in the repository, not per machine**: `.shellcheckrc` sets `disable=SC1090,SC1091`, `shell=bash`, `source-path=SCRIPTDIR`, `external-sources=true` and `severity=warning`.
- **Contributors find the ground rules in the repository**: `CONTRIBUTING.md`, `SECURITY.md` and `CODE_OF_CONDUCT.md`.
- **The documentation has an entry point**: `docs/README.md` links the four guides and says what each one answers.
- **The README shows whether the current state is green**: a CI status badge linked to the `lint.yml` workflow.

### Changed
- **The README states the platform, license and dependency situation at a glance**: the badge row went from 2 to 8, adding Release, Platform, CI, ShellCheck, Dependencies and Maintenance.

## [1.1.0] - 2026-01-17: The validator runs on macOS, and external links stop inflating the valid count

### Added
- **External links are reported separately from links that were actually checked**: `skipped_external_urls` counts `http`, `https`, `ftp` and `mailto` targets and appears in the summary and in the JSON output.
- **The validator runs on macOS and other BSD userlands**: `sed_inplace()` detects GNU and BSD `sed` and calls the right form, and the ten `grep -oP` calls of 1.0.1 are replaced by POSIX `grep -o` and `sed` patterns.
- **JSON output can be piped straight into a parser**: `--output-format=json` suppresses the scan and error lines that previously preceded the document.

### Fixed
- **External URLs no longer inflate the valid-link count**: they were counted as internal valid links; they now go to `skipped_external_urls`.
- **A line with several links has all of them checked**: the extraction pattern was `\[.*\]([^)]*.md[^)]*)`, whose greedy `.*` swallowed everything between the first `[` and the last `]` on the line. It is now `\[[^]]*\]([^)]*.md[^)]*)`.
- **Links to an explicit `id="..."` attribute resolve**: those anchors are normalized the same way as heading anchors.
- **Verbose mode no longer breaks JSON output**: the `--verbose` and scan lines are suppressed when `OUTPUT_FORMAT` is `json`.
- **The example wrappers resolve their own directory without GNU `readlink`**: `readlink -f` is replaced by `pwd -P` in `examples/basic-wrapper.sh` and `examples/multi-area-wrapper.sh`.

### Changed
- **The README says which platforms are supported and which are partial**: Linux, macOS and WSL2 are fully supported; a generic POSIX environment needs Bash 4.0 or newer.

### Technical details
- 146 lines changed across `src/validate-links-core.sh`, `examples/basic-wrapper.sh`, `examples/multi-area-wrapper.sh` and `README.md`.
- No function was removed or renamed; `sed_inplace()` is the only addition, so existing wrappers keep working.

## [1.0.1] - 2025-12-31: The two shipped example wrappers are documented

### Added
- **The example wrappers are findable from the README**: `README.md` and `docs/WRAPPER_SYSTEM.md` gained a table of `examples/basic-wrapper.sh` and `examples/multi-area-wrapper.sh` with the case each one covers. Both files shipped with 1.0.0 but were mentioned nowhere.

## [1.0.0] - 2025-12-31: First public release

### Added
- Initial release
- Smart anchor resolution: suffix matching, umlaut normalization and numbered-section matching in `normalize_anchor()` and `validate_anchor_exists()`
- Parallel processing with a configurable job count (`-j N`)
- JSON output for CI/CD integration (`OUTPUT_FORMAT=json`)
- Batch-fix mode for link pattern replacement
- Deep path warnings and automatic TODO marking
- Wrapper system for easy integration, with two ready-to-use examples

## Links

**Repository**: https://github.com/fidpa/bash-markdown-link-validator
**License**: MIT
