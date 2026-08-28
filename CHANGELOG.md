# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-08-28: An installed copy can report its own version

### Added
- **`--version` tells you which library a wrapper is running**: a copy installed under `~/.local/lib/` could only be identified by opening the file and reading a comment in its header. `parse_args()` now accepts `-V` and `--version` and prints `validate-links-core.sh <version>` before exiting with 0, the same way `--help` does.

### Changed
- **The version lives in one place instead of two**: `SCRIPT_VERSION` in `src/validate-links-core.sh` is the single source, and the `# Version:` comment in the file header is gone. The footer of `docs/API_REFERENCE.md` carried a second copy that was four releases behind until 1.2.3; it is replaced by a pointer to `--version`. The constant is guarded (`[[ -v SCRIPT_VERSION ]] || readonly ...`) because a wrapper may source the library more than once, and a second `readonly` on the same name writes to stderr, which would land in the JSON stream.
- **The production figures in `README.md` and `docs/QUICK_START.md` describe a run that was measured**: they said 2,271 files and 11,000+ links "validated daily" across 11 deployments, in production "since July 2025". Measured on 2026-08-28 over the seven wrappers of the tree the library grew up in: 3,251 files, 16,646 links, 8,783 of them internal and validated. There are seven wrappers, not 11. Nothing schedules the run, so "daily" is gone. The first wrapper was committed on 2025-08-18, so the starting point is August 2025.

### Fixed
- **`--help` lists the options once**: a stray second `OPTIONS:` line split the option list in `show_usage()`, so everything from `--output-format` onwards looked like a separate group.

### Upgrade notes
- **A wrapper that writes `EXCLUDE_DIRS="a\|b"` with an escaped pipe stops excluding anything.** That form was the one that worked before 1.2.5, because the filter ran as a basic regular expression; under the extended one it is a literal `|`. Wrappers written that way exclude nothing from 1.2.5 onwards and will report more files, more links and possibly more broken links than before. The fix is to drop the backslashes: `EXCLUDE_DIRS="a|b"`. The `### Upgrade notes` block of 1.2.5 describes only the opposite direction, which is where this note belongs.

## [1.2.5] - 2026-08-28: EXCLUDE_DIRS with alternation excludes the directories it names

### Fixed
- **`EXCLUDE_DIRS="archive|deprecated"` now skips both directories instead of neither**: `find_markdown_files()` filtered with `grep -v "/$exclude_dirs/"`, a basic regular expression in which `|` is a literal character, so the pattern matched no path and nothing was excluded. It is now `grep -vE "/($exclude_dirs)/"`. A single directory name (`EXCLUDE_DIRS="archive"`) behaved correctly before and is unaffected. Measured on a fixture with `archive/`, `deprecated/`, `drafts/` and `keep/`: the alternation form returned all five files before the change and three after it.
- **`CONTRIBUTING.md` describes a test run that can be performed**: the "Running Tests" section told contributors to `cd test/` and run `../src/validate-markdown-links.sh`. Neither the directory nor that file has ever existed in this repository, and the library is sourced by a wrapper rather than called. The section now says there is no test suite and shows the wrapper-based run instead. The JSON example in the same file used `--json`, which is not an option; the flag is `--output-format=json`.
- **`docs/README.md` no longer points at a `test/` directory or a `--json` flag**, for the same two reasons.
- **The document lengths in `docs/README.md` match the files**: they were roughly half the real values (`~100`/`~180`/`~300`/`~150` against 179/338/593/315 lines), and the total said `~650` where the four guides add up to 1425. The same applies to the two example wrappers in `docs/WRAPPER_SYSTEM.md`, listed as `~60` and `~150` lines against 90 and 225.
- **The security audit history in `SECURITY.md` carries the years the releases happened**: it dated v1.0.0 to 2024-12 and v1.1.0 to 2025-01, one year before their tags (2025-12-31 and 2026-01-17).

### Upgrade notes
- **Wrappers that pass an alternation to `EXCLUDE_DIRS` will report fewer files and fewer links than before.** Those directories were being validated all along, so findings inside them disappear from the report and a pipeline that failed on them can turn green. Check the counts in the summary against the previous run before treating the change as a regression.

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
