#!/bin/bash
set -e

# ShipGuard CloudFormation Template Validation Script
# Validates all infrastructure templates using cfn-lint

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TEMPLATES=(
  "$PROJECT_ROOT/infrastructure/staging.yaml"
  "$PROJECT_ROOT/infrastructure/production.yaml"
  "$PROJECT_ROOT/infrastructure/pipeline.yaml"
)

FAILED=0
PASSED=0

echo "============================================"
echo "ShipGuard CloudFormation Template Validation"
echo "============================================"
echo ""

# Check if cfn-lint is installed, install if not
if ! command -v cfn-lint &> /dev/null; then
  echo "cfn-lint not found. Installing..."
  pip install cfn-lint --quiet
  if ! command -v cfn-lint &> /dev/null; then
    echo "ERROR: Failed to install cfn-lint"
    exit 1
  fi
  echo "cfn-lint installed successfully."
  echo ""
fi

# Run cfn-lint on each template
echo "Running cfn-lint validation..."
echo "--------------------------------------------"

for template in "${TEMPLATES[@]}"; do
  template_name=$(basename "$template")
  echo -n "  Validating $template_name... "

  if cfn-lint "$template" 2>&1; then
    echo "PASSED"
    ((PASSED++))
  else
    echo "FAILED"
    ((FAILED++))
  fi
  echo ""
done

# Summary
echo "--------------------------------------------"
echo "Results: $PASSED passed, $FAILED failed"
echo "============================================"

if [ $FAILED -ne 0 ]; then
  echo "Template validation FAILED"
  exit 1
fi

echo "All templates passed validation!"
exit 0
