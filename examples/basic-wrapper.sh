#!/bin/bash
# Copyright (c) 2025 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/bash-markdown-link-validator
#
# Basic wrapper example - validates links in a single directory
#
# Usage: ./basic-wrapper.sh [OPTIONS]
#
# Copy this file to your documentation directory and customize
# the configuration section below.

set -uo pipefail

# ============================================================================
# CONFIGURATION - Customize these for your project
# ============================================================================

AREA_NAME="docs"                        # Display name for reports
EXCLUDE_DIRS="archive|deprecated"       # Directories to exclude (regex)

# ============================================================================
# PATH SETUP - Adjust if your project structure differs
# ============================================================================

# This script's directory (where your docs are)
readonly AREA_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

# Project root (parent of docs)
readonly PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"

# Main docs directory
readonly DOCS_DIR="$PROJECT_ROOT/docs"

# ============================================================================
# LIBRARY LOADING - Update path as needed
# ============================================================================

# Option 1: Installed globally
# LIBRARY_PATH="${HOME}/.local/lib/bash-markdown-link-validator/validate-links-core.sh"

# Option 2: In project's scripts/lib directory
# LIBRARY_PATH="$PROJECT_ROOT/scripts/lib/validate-links-core.sh"

# Option 3: Relative to this script (if examples/ is in the repo)
LIBRARY_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src/validate-links-core.sh"

if [[ ! -f "$LIBRARY_PATH" ]]; then
    echo "ERROR: Cannot find validate-links-core.sh at: $LIBRARY_PATH" >&2
    echo "Please update LIBRARY_PATH in this script." >&2
    exit 2
fi

# shellcheck source=/dev/null
source "$LIBRARY_PATH" || {
    echo "ERROR: Failed to load library" >&2
    exit 2
}

# ============================================================================
# MAIN
# ============================================================================

parse_args "$@"
setup_colors
print_validation_header

# Find markdown files
mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")

if [[ ${#md_files[@]} -eq 0 ]]; then
    echo "No markdown files found in $AREA_DIR"
    exit 0
fi

echo "Found ${#md_files[@]} markdown files"
echo ""

# Run validation
if [[ $PARALLEL_JOBS -eq 1 ]]; then
    validate_sequential "${md_files[@]}"
else
    validate_parallel "${md_files[@]}"
fi

# Output summary
print_summary_report

# Exit with appropriate code
exit_with_status
