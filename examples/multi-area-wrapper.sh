#!/bin/bash
# Copyright (c) 2025 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/bash-markdown-link-validator
#
# Multi-area wrapper example - validates links across multiple documentation areas
#
# Usage: ./multi-area-wrapper.sh [OPTIONS]
#
# This example validates all DIATAXIS-style documentation areas:
# tutorial, how-to, reference, explanation
#
# Perfect for CI/CD pipelines where you want to validate all docs at once.

set -uo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

# Define your documentation areas
# Format: "area_name:relative_path:exclude_pattern"
AREAS=(
    "tutorial:docs/tutorial:archive"
    "how-to:docs/how-to:archive|deprecated"
    "reference:docs/reference:archive"
    "explanation:docs/explanation:archive"
)

# Global settings
PARALLEL_JOBS_PER_AREA=2
STOP_ON_ERROR=false
OUTPUT_FORMAT="text"  # text or json

# ============================================================================
# PATH SETUP
# ============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly DOCS_DIR="$PROJECT_ROOT/docs"

# Library path (update as needed)
LIBRARY_PATH="$SCRIPT_DIR/../src/validate-links-core.sh"

if [[ ! -f "$LIBRARY_PATH" ]]; then
    echo "ERROR: Cannot find validate-links-core.sh at: $LIBRARY_PATH" >&2
    exit 2
fi

# ============================================================================
# PARSE ARGUMENTS
# ============================================================================

VERBOSE=false
NO_COLOR=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --no-color)
            NO_COLOR=true
            shift
            ;;
        -j|--parallel-jobs)
            PARALLEL_JOBS_PER_AREA="$2"
            shift 2
            ;;
        --stop-on-error)
            STOP_ON_ERROR=true
            shift
            ;;
        --output-format=*)
            OUTPUT_FORMAT="${1#*=}"
            shift
            ;;
        -h|--help)
            cat << EOF
Usage: $0 [OPTIONS]

Validates all documentation areas in sequence.

OPTIONS:
    -v, --verbose           Show detailed output
    --no-color              Disable colored output
    -j N, --parallel-jobs N Jobs per area (default: 2)
    --stop-on-error         Stop on first area with errors
    --output-format=FORMAT  text (default) or json
    -h, --help              Show this help

AREAS VALIDATED:
$(for area in "${AREAS[@]}"; do
    IFS=: read -r name path _ <<< "$area"
    echo "  - $name ($path)"
done)

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 2
            ;;
    esac
done

# ============================================================================
# COLORS
# ============================================================================

if [[ $NO_COLOR == false ]] && [[ -t 1 ]]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    GREEN="" RED="" YELLOW="" BLUE="" NC=""
fi

# ============================================================================
# MAIN
# ============================================================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE} Multi-Area Link Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

total_areas=0
failed_areas=0
total_broken=0

for area_config in "${AREAS[@]}"; do
    # Parse area config
    IFS=: read -r area_name area_path exclude_pattern <<< "$area_config"

    area_dir="$PROJECT_ROOT/$area_path"

    if [[ ! -d "$area_dir" ]]; then
        echo -e "${YELLOW}⚠ Skipping $area_name: directory not found ($area_dir)${NC}"
        continue
    fi

    total_areas=$((total_areas + 1))

    echo -e "${BLUE}>>> Validating: $area_name${NC}"
    echo "    Path: $area_path"
    echo ""

    # Set up environment for library
    export AREA_NAME="$area_name"
    export AREA_DIR="$area_dir"
    export PROJECT_ROOT
    export DOCS_DIR
    export EXCLUDE_DIRS="$exclude_pattern"
    export VERBOSE
    export PARALLEL_JOBS="$PARALLEL_JOBS_PER_AREA"
    export OUTPUT_FORMAT

    # Reset counters
    export total_files=0
    export total_links=0
    export valid_links=0
    export broken_links=0
    export warnings=0

    # Source library fresh for each area
    # shellcheck source=/dev/null
    source "$LIBRARY_PATH"

    # Run validation
    setup_colors
    mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")

    if [[ ${#md_files[@]} -eq 0 ]]; then
        echo "    No markdown files found"
    else
        if [[ $PARALLEL_JOBS -eq 1 ]]; then
            validate_sequential "${md_files[@]}"
        else
            validate_parallel "${md_files[@]}"
        fi

        # Summary for this area
        if [[ $broken_links -gt 0 ]]; then
            echo -e "    ${RED}✗ $broken_links broken links${NC}"
            failed_areas=$((failed_areas + 1))
            total_broken=$((total_broken + broken_links))

            if [[ $STOP_ON_ERROR == true ]]; then
                echo ""
                echo -e "${RED}Stopping due to errors (--stop-on-error)${NC}"
                exit 1
            fi
        else
            echo -e "    ${GREEN}✓ All ${total_links} links valid${NC}"
        fi
    fi

    echo ""
done

# ============================================================================
# FINAL SUMMARY
# ============================================================================

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE} Final Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Areas validated: $total_areas"
echo "Areas with errors: $failed_areas"
echo "Total broken links: $total_broken"
echo ""

if [[ $failed_areas -eq 0 ]]; then
    echo -e "${GREEN}✓ All areas validated successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ $failed_areas area(s) have broken links${NC}"
    exit 1
fi
