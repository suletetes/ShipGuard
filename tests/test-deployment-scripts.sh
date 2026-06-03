#!/bin/bash
# test-deployment-scripts.sh - Unit tests for deployment scripts
# Validates deployment script contents using static analysis (grep-based checks)
# No external test framework required

set -e

SCRIPTS_DIR="$(cd "$(dirname "$0")/../scripts" && pwd)"
PASS=0
FAIL=0

# Helper function to report test results
pass() {
  echo "  PASS: $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  FAIL: $1"
  FAIL=$((FAIL + 1))
}

assert_file_exists() {
  if [ -f "$1" ]; then
    pass "$2 - file exists"
  else
    fail "$2 - file exists (not found: $1)"
  fi
}

assert_file_readable() {
  if [ -r "$1" ]; then
    pass "$2 - file is readable"
  else
    fail "$2 - file is readable"
  fi
}

assert_has_shebang() {
  if head -n 1 "$1" | grep -q '^#!/bin/bash'; then
    pass "$2 - has #!/bin/bash shebang"
  else
    fail "$2 - has #!/bin/bash shebang"
  fi
}

assert_has_set_e() {
  if grep -q '^set -e' "$1"; then
    pass "$2 - uses set -e"
  else
    fail "$2 - uses set -e"
  fi
}

assert_contains() {
  if grep -q "$3" "$1"; then
    pass "$2 - contains $4"
  else
    fail "$2 - contains $4"
  fi
}

echo "========================================"
echo "Deployment Script Unit Tests"
echo "========================================"
echo ""
echo "Scripts directory: ${SCRIPTS_DIR}"
echo ""

# ----------------------------------------
# Test: validate_service.sh
# ----------------------------------------
echo "--- validate_service.sh ---"
SCRIPT="${SCRIPTS_DIR}/validate_service.sh"

assert_file_exists "$SCRIPT" "validate_service.sh"
assert_file_readable "$SCRIPT" "validate_service.sh"
assert_has_shebang "$SCRIPT" "validate_service.sh"
assert_has_set_e "$SCRIPT" "validate_service.sh"
assert_contains "$SCRIPT" "validate_service.sh" "TIMEOUT" "TIMEOUT variable"
assert_contains "$SCRIPT" "validate_service.sh" "INTERVAL" "INTERVAL variable"
assert_contains "$SCRIPT" "validate_service.sh" "curl" "curl command"
assert_contains "$SCRIPT" "validate_service.sh" "sleep" "sleep command"
assert_contains "$SCRIPT" "validate_service.sh" "exit 1" "exit 1 on failure"
assert_contains "$SCRIPT" "validate_service.sh" "exit 0" "exit 0 on success"

echo ""

# ----------------------------------------
# Test: before_install.sh
# ----------------------------------------
echo "--- before_install.sh ---"
SCRIPT="${SCRIPTS_DIR}/before_install.sh"

assert_file_exists "$SCRIPT" "before_install.sh"
assert_file_readable "$SCRIPT" "before_install.sh"
assert_has_shebang "$SCRIPT" "before_install.sh"
assert_has_set_e "$SCRIPT" "before_install.sh"
assert_contains "$SCRIPT" "before_install.sh" 'systemctl stop.*|| true' "systemctl stop with || true (graceful handling)"
assert_contains "$SCRIPT" "before_install.sh" 'rm -rf /opt/cloudpulse' "rm -rf /opt/cloudpulse"

echo ""

# ----------------------------------------
# Test: after_install.sh
# ----------------------------------------
echo "--- after_install.sh ---"
SCRIPT="${SCRIPTS_DIR}/after_install.sh"

assert_file_exists "$SCRIPT" "after_install.sh"
assert_file_readable "$SCRIPT" "after_install.sh"
assert_has_shebang "$SCRIPT" "after_install.sh"
assert_has_set_e "$SCRIPT" "after_install.sh"
assert_contains "$SCRIPT" "after_install.sh" 'npm ci --production' "npm ci --production"
assert_contains "$SCRIPT" "after_install.sh" 'chown' "chown command for ownership"
assert_contains "$SCRIPT" "after_install.sh" 'chmod' "chmod command for permissions"

echo ""

# ----------------------------------------
# Test: start_application.sh
# ----------------------------------------
echo "--- start_application.sh ---"
SCRIPT="${SCRIPTS_DIR}/start_application.sh"

assert_file_exists "$SCRIPT" "start_application.sh"
assert_file_readable "$SCRIPT" "start_application.sh"
assert_has_shebang "$SCRIPT" "start_application.sh"
assert_has_set_e "$SCRIPT" "start_application.sh"
assert_contains "$SCRIPT" "start_application.sh" 'systemctl start' "systemctl start command"

echo ""

# ----------------------------------------
# Summary
# ----------------------------------------
echo "========================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo "========================================"

if [ $FAIL -gt 0 ]; then
  exit 1
fi

exit 0
