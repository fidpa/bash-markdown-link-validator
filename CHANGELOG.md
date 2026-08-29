# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.6.0] - 2026-08-29: Directory links are checked because the pattern says so, not because the name happens to match

### Fixed
- **The extraction pattern means what it says**: both scanners looked for links with `grep '\[[^]]*\]([^)]*.md[^)]*)'`, in which the dot is unescaped and therefore matches any character. `[logo](img/amd-logo.png)` was scanned as if it were Markdown, `[notes](notes-md-draft.txt)` likewise, and the directory resolution added in v1.4.0 was reachable only when the directory name itself satisfied the accident: `[systemd](systemd/)` matched through "emd" and was checked, `[network](network/)` was never looked at. Measured over the documentation tree the library grew up in: of 1189 directory links, 18 were being checked. The pattern now lives in one place as the read-only `LINK_PATTERN` and admits two shapes deliberately, a target containing `.md` and a directory link ending in `/`; colons are excluded from the second so that external URLs are not pulled in.
- **A directory without a landing page says so**: such a link was reported as `File not found: empty/`, which sends the reader looking for a path that is in fact there. It is now `Directory has no README.md`, typed `directory_without_readme` in the JSON output and counted exactly as before. Found by the library on its own repository: `docs/README.md` linked to `../examples/`, a directory that had no `README.md` until this release.

### Added
- **`examples/README.md`**: the examples directory now has the landing page its own documentation linked to, naming which wrapper covers which case and pointing at `docs/WRAPPER_SYSTEM.md` for the pattern behind them.

### Changed
- **`docs/API_REFERENCE.md` documents `LINK_PATTERN`** under Global Variables, notes the new JSON error type next to `file_not_found`, and states plainly that the directory branch was mostly unreachable before this release. `README.md` moves directory resolution from the list of limits into the feature list, where it now belongs.

### Upgrade notes
- **A run will report more broken links than before, and a green pipeline can turn red.** Nothing became stricter: links that were always broken are now visible, because the scanners finally look at them. Measured over a 4358-file documentation tree: 18211 links checked before against 19054 after, and 534 broken findings before against 613 after. Of the 843 links that came into view, 764 were fine. The new findings are directory links pointing at a directory that does not exist, or at one without a `README.md`.
- **`Skipped external URLs` drops.** In the same run it went from 61 to 18. External URLs were never fetched; the count previously included any URL whose text happened to satisfy the unescaped dot, and now covers only URLs that really do end in `.md`.
- **Two error strings changed** for anyone grepping the text output: `File not found` still applies to a path that is not there, while a directory that exists without a `README.md` now reports `Directory has no README.md`. In JSON, `type` is `directory_without_readme` for that case.

## [1.5.0] - 2026-08-29: The internal/external counts add up, the JSON parses, and the README names its limits

### Fixed
- **The internal/external breakdown adds up again**: `scan_file()` and `scan_file_parallel()` counted a link towards "Internal links" or "External links" only when it was valid, so a report could claim 6 links found and 1 internal plus 1 external in the same block. `validate_link()` now returns 4 for a broken external link and 5 for an external anchor warning, next to the existing 1 and 2 for the internal cases, and both scanners derive the scope from `result >= 3` before they classify the outcome. Measured on a directory with one valid, one broken and one warned link per scope: before, "Internal 1 / External 1" against 6 links found; after, "Internal 3 / External 3", and "Internal valid 2 / External valid 2" against 4 valid. The parallel path carries the two new counters as `vint=` and `vext=` in its `STATS:` line, deliberately named so that the greedy `sed` patterns in `aggregate_parallel_stats()` cannot latch onto the wrong field.
- **`--output-format=json` emits valid JSON**: `print_json_report()` interpolated `AREA_NAME`, file paths and link targets into string literals unescaped, so a single quote in a path was enough to break every parser downstream, the case the source marked as a TODO. A `json_escape()` function now escapes backslash, quote, tab, carriage return and newline, in that order, and every string field passes through it. Measured against a file named `say "hi".md` and an area name carrying a quote and a backslash: `json.load()` rejected the old output at line 3, and accepts the new one.

### Changed
- **`README.md` states what the validator does not check**: the page listed strengths only. It now carries a "What it does not check" section directly after the features, naming the five limits a reader would otherwise discover by surprise: external URLs are counted and skipped rather than fetched, links whose target lacks `.md` never reach the validator at all (the extraction pattern in `scan_file()` requires it, which is why a run over this repository counts four links in `README.md`), a missing anchor is a warning that leaves the exit code at 0, `print_json_report()` emits unescaped strings, and there is no test suite behind the "production tested" claim.
- **`docs/API_REFERENCE.md` describes the counters that exist**: the global-variable table explained `total_links_internal` as "Internal links" without saying whether a broken link counts, and did not list `valid_links_internal`/`valid_links_external` at all. The sample JSON carried the arithmetic of the bug fixed above (1768 internal plus 901 external against 2822 links found) and omitted `skipped_external_urls`, a field the report has emitted since v1.1.0.
- **The CLI reference quotes `show_usage()` verbatim**: the hand-written option table was missing `--no-deep-path-warning`, `--max-path-depth=N` and `-h, --help`, and rendered `--output-format=FORMAT` as `--output-format=json`. The block is now the help output itself, exit codes included.
- **Every claim in the README has a source in the repository**: the file counts, link counts and deployment count ("3,251 files", "16,646 links", "8,783 of them internal", "seven active deployments") came from a private documentation tree, could not be reproduced by any reader and depended on an exclude list the page never showed. They are gone; the provenance stays in the acknowledgments. The sample output is a real run over a directory with one deleted target and one mistyped anchor, produced by the wrapper the Quick Start prints. The installation section describes what `install.sh` actually does: it copies the library to `~/.local/lib/bash-markdown-link-validator/` and writes a sample wrapper, it does not copy `src/`.
- **The comparison table shows this tool's own weakness**: it gained an "External URLs" column, where the entry for this validator is the only "not checked" alongside lychee, markdown-link-check and linkchecker, with the trade-off spelled out underneath.
- **Platform support is stated in honest grades**: macOS was listed as "full support" without mentioning that Apple ships Bash 3.2 and that Homebrew's Bash is required, a condition `install.sh` enforces and `docs/TROUBLESHOOTING.md` already documented. Linux and WSL2 are covered by CI, macOS is not, and Bash 3.x is now named as unsupported rather than left to the reader.
- **The anchor section describes the algorithm that runs**: normalization (lowercase, umlaut transliteration, GitHub's punctuation rule) is separated from the three matching strategies, and the narrow scope of suffix matching is stated: it applies only to anchors without a section number and only against headings numbered `N-N-`.

### Upgrade notes
- **Only callers of `validate_link()` need to act.** The function gained two return codes: 4 for a broken external link and 5 for an external anchor warning, where it previously returned 1 and 2 for those cases. Wrapper scripts built on the documented entry points (`parse_args`, `setup_colors`, `find_markdown_files`, `validate_sequential`, `validate_parallel`, `print_summary_report`, `exit_with_status`) are unaffected, and the two shipped examples need no change. Code that calls `validate_link()` directly and tests `result -eq 1` or `result -eq 2` should test `result -eq 1 || result -eq 4` and `result -eq 2 || result -eq 5`, or use the scope rule the library itself follows: `result >= 3` means external, `0`/`3` valid, `2`/`5` warning, the rest broken.
- **The script exit codes are unchanged**: 0 for all links valid, 1 for broken links, 2 for a script error. A pipeline that was green stays green, because the same set of links is checked as before; what changed is which scope a broken or warned link is counted under in the summary and in `internal_links`/`external_links` of the JSON report.


## [1.4.0] - 2026-08-28: Directory links and GitHub's anchor rule stop producing false findings

### Added
- **A link to a directory resolves to its `README.md`**: `[systemd](../reference/systemd/)` was reported as `File not found` even though the directory existed and contained a `README.md`, the file GitHub and every other Markdown renderer show for such a link. `validate_link()` now redirects a directory target to `<dir>/README.md` before the existence check. A directory without a `README.md` stays a broken link, because there is no page to land on. Measured over the tree the library grew up in: 10 findings across 9 files, every one of them a directory that existed and carried a `README.md`.

### Fixed
- **`normalize_anchor()` follows GitHub's rule for punctuation**: it replaced *every* character outside `a-z0-9` with a hyphen, so the heading `## Warum SECURITY.md?` produced `warum-security-md`. GitHub removes punctuation and turns only spaces into hyphens, giving `warum-securitymd`. A table of contents written the way the page actually renders therefore counted as broken. The filter is now `s/[^a-z0-9 -]//g; s/ /-/g`; collapsing repeated hyphens and trimming the edges stays, because it applies to the heading and the link alike and only makes the comparison more forgiving.
- **Emoji in a heading no longer depends on the locale**: the `sed` filter runs under `LC_ALL=C`. Under a UTF-8 locale GNU sed leaves four-byte characters inside a negated character class, so `## ⚙️ SystemD Tutorials 🆕` kept its `🆕` in the anchor while `⚙️` was dropped, and a correct link to it was reported. Under `LC_ALL=C` the filter works byte-wise and removes both. The umlauts are transliterated before this step, so nothing is lost. Measured on `de_DE.UTF-8` against `C`: the same heading produced `systemd-tutorials-3-tutorials-🆕` and `systemd-tutorials-3-tutorials`.

### Changed
- **`docs/API_REFERENCE.md` describes the algorithm that runs**: the `normalize_anchor()` steps listed four operations and omitted the uppercase-umlaut transliteration added in 1.2.1; the example output `api-reference-v2-0` is now `api-reference-v20`. The `validate_link()` entry gained the directory rule. `docs/TROUBLESHOOTING.md` carried the same outdated example and gains the punctuation case next to the umlaut one.

- **The repository page shows the MIT licence, and licence-filtered searches find the project.** `LICENSE` carried the repository URL on its own line under the copyright notice. GitHub reads a licence text with an extra line as modified and reports `NOASSERTION`, which leaves the licence field on the repository page empty. The line is gone; the MIT text and the copyright notice are byte-for-byte unchanged, and the URL is still in `README.md`.

### Upgrade notes
- **The anchor change can turn warnings on links that were silently accepted before.** A link written for the old rule (`#2-5-troubleshooting` for the heading `## 2.5 Troubleshooting`) matched only because the heading was normalized the same wrong way. It does not work on GitHub and is now reported as `Anchor not found`. Measured over the tree the library grew up in: 36 such links surfaced, against 12 warnings that disappeared. They are genuine broken anchors, not regressions; the correct form is the one GitHub produces (`#25-troubleshooting`). Compare the warning count against the previous run before treating the change as a regression.
- **The directory rule lowers the broken-link count.** Links to directories with a `README.md` were being reported all along; those findings disappear and a pipeline that failed on them can turn green.

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
