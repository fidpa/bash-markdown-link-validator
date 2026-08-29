# API Reference

## ⚡ TL;DR

Complete function reference for the link validation library (20+ functions).

---

## 📋 Function Index

| Function | Category | Exported | Description |
|----------|----------|----------|-------------|
| `setup_colors()` | Setup | ✅ | TTY-aware color initialization |
| `normalize_anchor()` | Anchor | ✅ | GitHub-compatible anchor normalization |
| `build_anchor_index()` | Anchor | ✅ | Build anchor cache for a file |
| `validate_anchor_exists()` | Anchor | ✅ | Cached anchor validation |
| `count_path_depth()` | Path | ✅ | Count ../ levels in path |
| `warn_deep_path()` | Path | ✅ | Warn on deep relative paths |
| `normalize_relative_path()` | Path | ✅ | Normalize redundant paths |
| `warm_anchor_cache()` | Cache | - | Pre-build anchor cache |
| `escape_sed_pattern()` | Security | ✅ | Escape string for sed pattern |
| `escape_sed_replacement()` | Security | ✅ | Escape string for sed replacement |
| `json_escape()` | Security | ✅ | Escape string for a JSON string literal |
| `apply_batch_fix()` | Fix | ✅ | Batch-fix for link patterns |
| `mark_as_todo()` | Fix | ✅ | Auto-TODO for missing files |
| `resolve_relative_path()` | Path | ✅ | Relative path resolution |
| `validate_link()` | Validation | ✅ | Core link validation |
| `scan_file()` | Scanning | - | Sequential file scanner |
| `scan_file_parallel()` | Scanning | ✅ | Parallel file scanner |
| `aggregate_parallel_stats()` | Stats | - | Parallel stats aggregation |
| `find_markdown_files()` | Discovery | - | Markdown file discovery |
| `parse_args()` | CLI | - | Argument parser |
| `print_validation_header()` | Output | - | Header output |
| `print_summary_report()` | Output | - | Summary output (JSON support) |
| `print_json_report()` | Output | - | JSON output for CI/CD |
| `exit_with_status()` | Control | - | Exit code handler |

---

## 🆕 CLI Options

| Option | Description |
|--------|-------------|
| `-v, --verbose` | Show detailed output for all links |
| `--no-color` | Disable colored output |
| `-j N, --parallel-jobs=N` | Run N parallel jobs (default: 2) |
| `-V, --version` | Print the library version and exit |
| `--output-format=json` | JSON output for CI/CD integration |
| `--fix-pattern=OLD:NEW` | Batch-fix for link patterns |
| `--auto-todo` | Mark missing files as TODO |
| `--no-deep-path-warning` | Disable deep path warnings |
| `--max-path-depth=N` | Max ../ levels before warning (default: 5) |
| `--warm-cache` | Pre-build anchor cache for all files |

---

## 🌐 Global Variables

### Required (must be set by caller)

| Variable | Type | Description |
|----------|------|-------------|
| `AREA_NAME` | string | Name of the area (for output) |
| `AREA_DIR` | path | Base directory for scanning |
| `PROJECT_ROOT` | path | Repository root |
| `DOCS_DIR` | path | `/docs` directory |
| `EXCLUDE_DIRS` | string | Directories to exclude (regex) |

### Configuration Options

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `VERBOSE` | bool | false | Verbose mode flag |
| `COLOR_OUTPUT` | bool | true | Color output flag |
| `PARALLEL_JOBS` | int | 2 | Number of parallel jobs |
| `OUTPUT_FORMAT` | string | text | Output format: text or json |
| `FIX_PATTERN` | string | "" | OLD:NEW for batch-fix |
| `AUTO_TODO` | bool | false | Auto-TODO enabled |
| `WARN_DEEP_PATHS` | bool | true | Deep path warnings |
| `MAX_PATH_DEPTH` | int | 5 | Max ../ levels |

**`LINK_PATTERN`** (read-only, set by the library) is the extended regular
expression deciding which links the scanners look at: a target containing `.md`,
or a directory link ending in `/`. Colons are excluded from the directory
alternative so that external URLs are not pulled in. Overriding it is not
supported; it is guarded against a second `source` like `SCRIPT_VERSION`.

### Counters (managed by library)

| Variable | Type | Description |
|----------|------|-------------|
| `total_files` | int | Scanned files |
| `total_links` | int | Found links |
| `valid_links` | int | Valid links |
| `broken_links` | int | Broken links |
| `warnings` | int | Warnings |
| `total_links_internal` | int | Links whose target lies inside `AREA_DIR`, valid or not |
| `total_links_external` | int | Links whose target lies outside `AREA_DIR`, valid or not |
| `valid_links_internal` | int | Valid share of `total_links_internal` |
| `valid_links_external` | int | Valid share of `total_links_external` |
| `deep_path_warnings` | int | Deep path warnings |
| `auto_todo_fixes` | int | Auto-TODO fixes |

---

## 🎨 Setup Functions

### setup_colors()

**Purpose**: Initialize color codes for terminal output (TTY-aware).

**Signature**:
```bash
setup_colors()
```

**Side Effects**:
- Sets global variables: `GREEN`, `RED`, `YELLOW`, `BLUE`, `CYAN`, `MAGENTA`, `NC`
- Exports variables for background jobs

**Behavior**:
- With TTY (`-t 1`): ANSI escape codes
- Without TTY (pipe/file): Empty strings

**Example**:
```bash
setup_colors
echo -e "${GREEN}✅${NC} Success"
echo -e "${RED}❌${NC} Error"
```

---

## 🔗 Anchor Functions

### normalize_anchor()

**Purpose**: Normalize anchor text to GitHub-compatible format.

**Signature**:
```bash
normalize_anchor <anchor>
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `anchor` | string | ✅ | Anchor text (with or without `#`) |

**Returns**: Normalized anchor (stdout)

**Algorithm**:
1. Remove leading `#`
2. Transliterate uppercase umlauts (Ä→a, Ö→o, Ü→u, ẞ→ss)
3. Convert to lowercase
4. Replace lowercase umlauts (ß→ss, ü→u, ö→o, ä→a)
5. Remove everything that is not `a-z`, `0-9`, a space or `-` — this is
   GitHub's rule: punctuation and symbols are dropped, not turned into hyphens
6. Turn spaces into `-`
7. Collapse repeated `-` and trim leading/trailing `-`

Steps 6 and 7 go beyond GitHub, which keeps repeated and edge hyphens. They
apply to the heading and the link alike, so they only make the comparison more
forgiving; a link written the way GitHub renders it always matches.

**Example**:
```bash
normalize_anchor "#My Section Title"
# Output: my-section-title

normalize_anchor "API Reference (v2.0)"
# Output: api-reference-v20

normalize_anchor "Größe und Übersicht"
# Output: grosse-und-ubersicht

normalize_anchor "Warum SECURITY.md?"
# Output: warum-securitymd
```

---

### build_anchor_index()

**Purpose**: Extract all anchors from a file and cache them.

**Signature**:
```bash
build_anchor_index <file>
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `file` | path | ✅ | Absolute path to markdown file |

**Side Effects**:
- Fills `ANCHOR_CACHE[$file]` (global associative array)

**Cache Format**:
```
anchor1
anchor2
anchor3
```

**Sources**:
- Markdown headers (`# Title`, `## Subtitle`, etc.)
- Explicit `id="..."` attributes

---

### validate_anchor_exists()

**Purpose**: Check if an anchor exists in a file (cached).

**Signature**:
```bash
validate_anchor_exists <file> <anchor>
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `file` | path | ✅ | Absolute path to target file |
| `anchor` | string | ✅ | Anchor to validate |

**Returns**:
- `0`: Anchor exists
- `1`: Anchor not found

**Features**:
- Exact match checking
- Fuzzy matching for numbered sections (#25- → #2-5-)
- Suffix matching for anchors without section numbers

---

## 📁 Path Functions

### resolve_relative_path()

**Purpose**: Resolve relative link path to absolute path.

**Signature**:
```bash
resolve_relative_path <base_file> <link>
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `base_file` | path | ✅ | Source file (absolute path) |
| `link` | string | ✅ | Relative link from markdown |

**Returns**: Absolute path (stdout)

**Path Types Handled**:
| Link Format | Handling |
|-------------|----------|
| `/absolute/path.md` | `$DOCS_DIR + link` |
| `../parent/file.md` | Relative resolution |
| `same-dir.md` | `dirname(base) + link` |

---

### count_path_depth()

**Purpose**: Count the number of `../` in a path.

**Signature**:
```bash
count_path_depth <path>
```

**Returns**: Integer (number of `../`)

**Example**:
```bash
count_path_depth "../../reference/core/README.md"
# Output: 2

count_path_depth "../../../../../docs/how-to/README.md"
# Output: 5
```

---

### warn_deep_path()

**Purpose**: Output warning if path depth exceeds MAX_PATH_DEPTH.

**Signature**:
```bash
warn_deep_path <source_file> <link> <line_num> <depth>
```

**Output**:
```
  📏 Line 42: Deep path (6 levels): ../../../../../../docs/reference/README.md
```

**Side Effects**:
- Increments `deep_path_warnings`
- Adds entry to `JSON_DEEP_PATHS` (for JSON output)

---

## 🔒 Security Functions

### escape_sed_pattern()

**Purpose**: Escape string for use as sed regex pattern.

**Signature**:
```bash
escape_sed_pattern <input>
```

**Escapes**: `. [ \ * ^ $ ( ) + ? { } |` and delimiters `/ |`

**Use Case**: Prevent sed injection/corruption with special characters in links.

---

### escape_sed_replacement()

**Purpose**: Escape string for use as sed replacement.

**Signature**:
```bash
escape_sed_replacement <input>
```

**Escapes**: `& \` and delimiter `/`

---

### json_escape()

**Purpose**: Escape a string for use inside a JSON string literal.

**Signature**:
```bash
json_escape <input>
```

**Returns**: Escaped string (stdout)

**Escapes**: `\` and `"`, plus tab, carriage return and newline. The backslash
is doubled first, so that the backslash introduced by the quote escape is not
escaped a second time.

**Used by**: `print_json_report()` for `AREA_NAME`, and every entry pushed into
`JSON_BROKEN_LINKS`, `JSON_WARNINGS` and `JSON_DEEP_PATHS`. A path containing a
quote used to produce output that no JSON parser would accept.

---

## ✅ Validation Functions

### validate_link()

**Purpose**: Core link validation (file + anchor).

**Signature**:
```bash
validate_link <source_file> <link> <line_num>
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `source_file` | path | ✅ | Source file |
| `link` | string | ✅ | Markdown link target |
| `line_num` | int | ✅ | Line number for output |

**Returns**:
| Code | Meaning |
|------|---------|
| `0` | Internal link valid |
| `1` | Internal link broken |
| `2` | Internal warning (anchor not found, but file exists) |
| `3` | External link valid |
| `4` | External link broken |
| `5` | External warning (anchor not found, but file exists) |

"External" means the resolved target lies outside `AREA_DIR`. Codes `3`, `4` and
`5` therefore share one rule: `result >= 3` is the scope test, `0`/`3` are valid,
`2`/`5` are warnings and everything else is broken. Callers written against the
older three-code contract keep working for valid links but count a broken or
warned external link as internal.

**Directory Links**:
A link whose target is a directory containing a `README.md` (`[systemd](../reference/systemd/)`)
resolves to that `README.md`, the file a Markdown renderer shows for it. A directory
without a `README.md` stays a broken link, reported as `Directory has no README.md`
and typed `directory_without_readme` in the JSON output, so that it can be told
apart from a path that does not exist at all.

Before v1.6.0 the scanners reached this branch only for directories whose name
happened to satisfy the extraction pattern; see `LINK_PATTERN` under Global
Variables.

**Skipped Links**:
- `https://`, `http://`, `ftp://`, `mailto:`

**Example**:
```bash
validate_link "/docs/how-to/guide.md" "../reference/api.md#usage" "42"
result=$?
case $result in
    0) echo "Internal valid" ;;
    1) echo "Broken" ;;
    2) echo "Warning" ;;
    3) echo "External valid" ;;
esac
```

---

## 📊 Scanning Functions

### scan_file()

**Purpose**: Sequential file scanner (single-threaded).

**Signature**:
```bash
scan_file <file>
```

**Side Effects**:
- Updates global counters: `total_files`, `total_links`, `valid_links`, `broken_links`
- Outputs progress to stdout

---

### scan_file_parallel()

**Purpose**: Parallel file scanner (background job).

**Signature**:
```bash
scan_file_parallel <file> <output_file>
```

**Parameters**:
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `file` | path | ✅ | Markdown file to scan |
| `output_file` | path | ✅ | Temp file for results |

**Output File Format**:
```
STATS: files=1 links=5 valid=5 broken=0 internal=3 external=2 warnings=0 deep=0 todo=0
SCANNING: relative/path.md
  ✓ 5 links, all valid (100%)
SUMMARY: ...
```

---

### validate_sequential() / validate_parallel()

**Purpose**: Orchestrate sequential or parallel validation.

**Signature**:
```bash
validate_sequential "${files[@]}"
validate_parallel "${files[@]}"
```

**Parameters**: Array of file paths

---

## 🔧 Fix Functions

### apply_batch_fix()

**Purpose**: Apply batch-fix pattern to link.

**Signature**:
```bash
apply_batch_fix <source_file> <link> <line_num>
```

**Returns**:
- `0`: Fix applied
- `1`: Pattern not found

**Side Effects**:
- Modifies `source_file` via `sed -i`

**Example**:
```bash
FIX_PATTERN="ref/ops/:ref/ops/maintenance/"
apply_batch_fix "docs/how-to/README.md" "../../ref/ops/UPDATE.md" 42
# Replaces link to "../../ref/ops/maintenance/UPDATE.md"
```

---

### mark_as_todo()

**Purpose**: Mark missing file as TODO in source document.

**Signature**:
```bash
mark_as_todo <source_file> <link> <line_num>
```

**Returns**:
- `0`: Marked as TODO
- `1`: Not marked (git history found or AUTO_TODO=false)

**Behavior**:
1. Check `AUTO_TODO` flag
2. Check git history for target file
3. If no history: Replace `[text](link)` with `` `filename.md` (TODO: to create) ``

---

### warm_anchor_cache()

**Purpose**: Pre-build anchor cache for all files.

**Signature**:
```bash
warm_anchor_cache <area_dir>
```

**Use Case**: Performance optimization for large areas with many cross-references.

---

## 📤 Output Functions

### print_validation_header()

**Purpose**: Output report header.

**Output**:
```
========================================
Link Validation Report - $AREA_NAME
========================================
```

---

### print_summary_report()

**Purpose**: Output summary report.

**Output**:
```
========================================
Summary
========================================
Total files scanned: 157
Total links found: 1001
  Internal links: 836
  External links: 85
Valid links: 926
  Internal valid: 836
  External valid: 85
Broken links: 75
Warnings: 5
Deep path warnings: 2
Success rate: 92%
========================================
```

---

### print_json_report()

**Purpose**: Output summary as JSON (for CI/CD).

**Output Format**:
```json
{
  "summary": {
    "area": "reference",
    "total_files": 563,
    "total_links": 2822,
    "internal_links": 1921,
    "external_links": 901,
    "valid_links": 2747,
    "broken_links": 75,
    "warnings": 12,
    "deep_path_warnings": 3,
    "auto_todo_fixes": 0,
    "skipped_external_urls": 44,
    "success_rate": 97
  },
  "broken_links": [
    {"file": "...", "line": 42, "link": "...", "type": "file_not_found"},
    {"file": "...", "line": 51, "link": "...", "type": "directory_without_readme"}
  ],
  "warnings": [
    {"file": "...", "line": 15, "link": "...", "type": "anchor_not_found"}
  ],
  "deep_paths": [
    {"file": "...", "line": 99, "link": "...", "depth": 6}
  ]
}
```

---

### exit_with_status()

**Purpose**: Exit script with correct exit code.

**Exit Codes**:
| Code | Condition |
|------|-----------|
| `0` | `broken_links == 0` |
| `1` | `broken_links > 0` |

---

## 🔍 Discovery Functions

### find_markdown_files()

**Purpose**: Find all markdown files in a directory.

**Signature**:
```bash
find_markdown_files <area_dir> <exclude_dirs>
```

**Returns**: Sorted list of markdown files (stdout, one per line)

**Example**:
```bash
mapfile -t files < <(find_markdown_files "$AREA_DIR" "archive")
echo "Found ${#files[@]} files"
```

---

## 📚 Related Documentation

- [Quick Start](QUICK_START.md) - Installation and basic usage
- [Wrapper System](WRAPPER_SYSTEM.md) - Multi-area validation pattern
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions

---

The version of an installed copy is what `--version` reports; this document
tracks the library it ships with.
