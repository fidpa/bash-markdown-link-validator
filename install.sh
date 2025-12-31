#!/bin/bash
# Copyright (c) 2025 Marc Allgeier (fidpa)
# SPDX-License-Identifier: MIT
# https://github.com/fidpa/bash-markdown-link-validator
#
# Installation helper for bash-markdown-link-validator

set -uo pipefail

# Default installation directory
INSTALL_DIR="${HOME}/.local/lib/bash-markdown-link-validator"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo " bash-markdown-link-validator Installer"
echo "=========================================="
echo ""

# Check bash version
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo -e "${RED}ERROR: Bash 4.0+ required${NC}"
    echo "Current version: $BASH_VERSION"
    echo ""
    echo "On macOS: brew install bash"
    exit 1
fi

echo -e "${GREEN}✓${NC} Bash version: $BASH_VERSION"

# Check required tools
for tool in grep sed find; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $tool: found"
    else
        echo -e "${RED}✗${NC} $tool: not found"
        exit 1
    fi
done

# Check optional tools
for tool in realpath git; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $tool: found (optional)"
    else
        echo -e "${YELLOW}⚠${NC} $tool: not found (optional)"
    fi
done

echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create installation directory
echo "Installing to: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR" || {
    echo -e "${RED}ERROR: Cannot create $INSTALL_DIR${NC}"
    exit 1
}

# Copy library
cp "$SCRIPT_DIR/src/validate-links-core.sh" "$INSTALL_DIR/" || {
    echo -e "${RED}ERROR: Cannot copy library${NC}"
    exit 1
}

echo -e "${GREEN}✓${NC} Library installed"

# Create a sample wrapper
SAMPLE_WRAPPER="$INSTALL_DIR/validate-links-sample.sh"
cat > "$SAMPLE_WRAPPER" << 'EOF'
#!/bin/bash
# Sample wrapper - copy and customize for your project
set -uo pipefail

# Configuration - CUSTOMIZE THESE
AREA_NAME="docs"
EXCLUDE_DIRS="archive|deprecated"

# Path setup
AREA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$AREA_DIR/.." && pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"

# Source library - UPDATE THIS PATH
source "${HOME}/.local/lib/bash-markdown-link-validator/validate-links-core.sh" || exit 2

# Run validation
parse_args "$@"
setup_colors
print_validation_header
mapfile -t md_files < <(find_markdown_files "$AREA_DIR" "$EXCLUDE_DIRS")

if [[ ${#md_files[@]} -eq 0 ]]; then
    echo "No markdown files found"
    exit 0
fi

if [[ $PARALLEL_JOBS -eq 1 ]]; then
    validate_sequential "${md_files[@]}"
else
    validate_parallel "${md_files[@]}"
fi

print_summary_report
exit_with_status
EOF

chmod +x "$SAMPLE_WRAPPER"
echo -e "${GREEN}✓${NC} Sample wrapper created"

echo ""
echo "=========================================="
echo " Installation Complete!"
echo "=========================================="
echo ""
echo "Library location:"
echo "  $INSTALL_DIR/validate-links-core.sh"
echo ""
echo "Sample wrapper:"
echo "  $SAMPLE_WRAPPER"
echo ""
echo "Next steps:"
echo "  1. Copy the sample wrapper to your project's docs directory"
echo "  2. Customize AREA_NAME and EXCLUDE_DIRS"
echo "  3. Update the library source path if needed"
echo "  4. Run: ./validate-links.sh"
echo ""
echo "Documentation: https://github.com/fidpa/bash-markdown-link-validator"
