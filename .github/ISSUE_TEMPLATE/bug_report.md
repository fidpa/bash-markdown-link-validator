---
name: Bug Report
about: Report a bug to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description

**Clear and concise description of the bug**

## Steps to Reproduce

1. Source the library: `source src/validate-links-core.sh`
2. Set the wrapper variables (`AREA_NAME`, `AREA_DIR`, `DOCS_DIR`)
3. Run the validation and observe the result

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Environment

- **Bash Version**: (run `bash --version`)
- **OS**: (e.g., Ubuntu 24.04, macOS 14.0)
- **Locale**: (run `locale`; anchor handling is locale-sensitive)
- **Validator Version**: (see `# Version:` in `src/validate-links-core.sh`)
- **ShellCheck Version**: (run `shellcheck --version`)

## Logs and Error Messages

```bash
# Paste relevant logs or error messages here
```

## Minimal Reproducible Example

```bash
#!/usr/bin/env bash
# Minimal wrapper plus a small Markdown file that reproduces the issue
set -uo pipefail
AREA_NAME="repro"
AREA_DIR="$PWD"
DOCS_DIR="$PWD"
source src/validate-links-core.sh

parse_args "$@"
setup_colors
mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "")
validate_sequential "${md_files[@]}"
print_summary_report
exit_with_status
```

## Additional Context

Any other context about the problem (e.g., related issues, workarounds tried).
