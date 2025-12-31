# Wrapper System - Multi-Area Validation

## ⚡ TL;DR

The wrapper system enables DRY validation of multiple documentation areas using a single core library. Create minimal wrappers (~20 lines) for each area instead of duplicating the entire validation logic.

---

## 📁 Ready-to-Use Examples

This repository includes two example wrappers:

| Example | Lines | Use Case |
|---------|-------|----------|
| [basic-wrapper.sh](../examples/basic-wrapper.sh) | ~60 | **Single directory** - validates one folder (e.g., `docs/`) |
| [multi-area-wrapper.sh](../examples/multi-area-wrapper.sh) | ~150 | **Multiple directories** - iterates over several areas with aggregated results |

### When to Use Which

**basic-wrapper.sh** - Choose this if:
- You have a single `docs/` folder
- You want one wrapper per area (DRY via library)
- Simple setup, minimal code

**multi-area-wrapper.sh** - Choose this if:
- You have multiple doc areas (DIATAXIS: tutorial, how-to, reference, explanation)
- You want one script to validate everything
- You need aggregated pass/fail results for CI/CD

---

## 🎯 Architecture

```
your-project/
├── docs/
│   ├── tutorial/
│   │   └── validate-links.sh      # Wrapper (~20 lines)
│   ├── how-to/
│   │   └── validate-links.sh      # Wrapper (~20 lines)
│   ├── reference/
│   │   └── validate-links.sh      # Wrapper (~20 lines)
│   └── explanation/
│       └── validate-links.sh      # Wrapper (~20 lines)
└── scripts/
    └── lib/
        └── validate-links-core.sh # Core library (900+ lines)
```

### Benefits

- **DRY Principle**: Single source of truth for validation logic
- **Easy Maintenance**: Update core library, all wrappers benefit
- **Flexible Configuration**: Each area can have custom settings
- **Consistent Output**: Same validation rules across all areas

---

## 📋 Wrapper Template

### Standard Wrapper

```bash
#!/bin/bash
# validate-links.sh - Place in your documentation area
set -uo pipefail

# ============================================================================
# CONFIGURATION - Customize these for your area
# ============================================================================

AREA_NAME="tutorial"                    # Display name for reports
EXCLUDE_DIRS="archive|deprecated"       # Directories to skip (regex)

# ============================================================================
# PATH SETUP - Usually doesn't need changes
# ============================================================================

readonly AREA_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/../.." && pwd)"
readonly DOCS_DIR="$PROJECT_ROOT/docs"

# Source the library (adjust path as needed)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/scripts/lib/validate-links-core.sh" || {
    echo "ERROR: Cannot load validate-links-core.sh" >&2
    exit 2
}

# ============================================================================
# MAIN
# ============================================================================

parse_args "$@"
setup_colors
print_validation_header

mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")

if [[ ${#md_files[@]} -eq 0 ]]; then
    echo "No markdown files found in $AREA_DIR"
    exit 0
fi

if [[ $PARALLEL_JOBS -eq 1 ]]; then
    validate_sequential "${md_files[@]}"
else
    validate_parallel "${md_files[@]}"
fi

print_summary_report
exit_with_status
```

---

## 🔧 Configuration Options

### AREA_NAME

The display name shown in reports. Should match your area's purpose:

```bash
AREA_NAME="tutorial"      # For docs/tutorial/
AREA_NAME="reference"     # For docs/reference/
AREA_NAME="scripts"       # For scripts/ directory
```

### EXCLUDE_DIRS

Regex pattern for directories to skip. Use `|` to combine patterns:

```bash
EXCLUDE_DIRS="archive"                    # Skip archive only
EXCLUDE_DIRS="archive|deprecated"         # Skip both
EXCLUDE_DIRS="archive|deprecated|drafts"  # Skip multiple
EXCLUDE_DIRS=""                           # Don't skip anything
```

### PROJECT_ROOT Calculation

For different directory depths:

```bash
# docs/area/validate-links.sh (2 levels up)
readonly PROJECT_ROOT="$(cd "$AREA_DIR/../.." && pwd)"

# docs/validate-links.sh (1 level up)
readonly PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"

# scripts/validate-links.sh (1 level up)
readonly PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"
```

---

## 📝 Examples

### DIATAXIS Documentation

For DIATAXIS-style documentation (tutorial, how-to, reference, explanation):

```bash
# docs/tutorial/validate-links.sh
AREA_NAME="tutorial"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/../.." && pwd)"
EXCLUDE_DIRS="archive"

# docs/how-to/validate-links.sh
AREA_NAME="how-to"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/../.." && pwd)"
EXCLUDE_DIRS="archive|deprecated"

# docs/reference/validate-links.sh
AREA_NAME="reference"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/../.." && pwd)"
EXCLUDE_DIRS="archive"

# docs/explanation/validate-links.sh
AREA_NAME="explanation"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/../.." && pwd)"
EXCLUDE_DIRS="archive"
```

### Single Area (No Subdirectories)

```bash
# docs/validate-links.sh
AREA_NAME="docs"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"
EXCLUDE_DIRS=""
```

### Scripts Directory

```bash
# scripts/validate-links.sh
AREA_NAME="scripts"
readonly AREA_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
readonly PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"
readonly DOCS_DIR="$PROJECT_ROOT/docs"  # Still reference main docs
EXCLUDE_DIRS="archive"
```

---

## 🏃 Running All Areas

### Sequential Execution

```bash
#!/bin/bash
# validate-all-docs.sh

echo "=== Validating all documentation areas ==="

for area in tutorial how-to reference explanation; do
    echo ""
    echo ">>> Validating $area..."
    ./docs/$area/validate-links.sh || true
done

echo ""
echo "=== Done ==="
```

### Parallel Execution (CI/CD)

```bash
#!/bin/bash
# validate-all-parallel.sh

# Run all wrappers in parallel
./docs/tutorial/validate-links.sh &
./docs/how-to/validate-links.sh &
./docs/reference/validate-links.sh &
./docs/explanation/validate-links.sh &

# Wait for all to complete
wait

echo "All areas validated"
```

---

## 🔄 CI/CD Integration

### GitHub Actions

```yaml
name: Validate Documentation Links

on:
  push:
    paths:
      - 'docs/**/*.md'
  pull_request:
    paths:
      - 'docs/**/*.md'

jobs:
  validate-links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Validate Tutorial Links
        run: ./docs/tutorial/validate-links.sh --output-format=json > tutorial-report.json

      - name: Validate Reference Links
        run: ./docs/reference/validate-links.sh --output-format=json > reference-report.json

      - name: Upload Reports
        uses: actions/upload-artifact@v4
        with:
          name: link-validation-reports
          path: '*-report.json'
```

### GitLab CI

```yaml
validate-docs:
  stage: test
  script:
    - ./docs/tutorial/validate-links.sh
    - ./docs/how-to/validate-links.sh
    - ./docs/reference/validate-links.sh
  only:
    changes:
      - docs/**/*.md
```

---

## 📊 JSON Output for CI/CD

Each wrapper supports JSON output for automated processing:

```bash
./docs/reference/validate-links.sh --output-format=json
```

Output:

```json
{
  "summary": {
    "area": "reference",
    "total_files": 563,
    "total_links": 2822,
    "internal_links": 2450,
    "external_links": 372,
    "valid_links": 2747,
    "broken_links": 75,
    "warnings": 12,
    "deep_path_warnings": 3,
    "auto_todo_fixes": 0,
    "success_rate": 97
  },
  "broken_links": [
    {"file": "reference/API.md", "line": 45, "link": "../how-to/DEPRECATED.md", "type": "file_not_found"}
  ],
  "warnings": [
    {"file": "reference/CONFIG.md", "line": 23, "link": "#old-section", "type": "anchor_not_found"}
  ],
  "deep_paths": []
}
```

---

## 📚 Related Documentation

- [Quick Start](QUICK_START.md) - Installation and basic usage
- [API Reference](API_REFERENCE.md) - Full function documentation
- [Troubleshooting](TROUBLESHOOTING.md) - Common issues and solutions
