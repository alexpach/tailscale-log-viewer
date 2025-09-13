#!/bin/bash

# Quick validation test - just test if validation rejects bad inputs
# We'll use a fake tailnet to prevent actual API calls

set -euo pipefail

# Ensure we're running from the project root
if [[ ! -f "ts-logs" ]]; then
    echo "Error: This test must be run from the project root directory" >&2
    echo "Usage: ./test/test_validation_only.sh" >&2
    exit 1
fi

# Use gtimeout on macOS if available, otherwise timeout
if command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_CMD="gtimeout"
elif command -v timeout >/dev/null 2>&1; then
    TIMEOUT_CMD="timeout"
else
    # No timeout command available, just run without timeout
    TIMEOUT_CMD=""
fi

SCRIPT="./ts-logs"
export TAILNET="test.com" # Set a test tailnet to avoid config error
export TAILSCALE_API_TOKEN="tskey-api-test-validation" # Fake token to avoid prompting

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "Testing numeric validation..."
echo "=============================="

test_validation() {
    local desc="$1"
    local args="$2"
    local should_fail="$3"

    echo -n "Testing: $desc ... "

    # Try to run the command, capture stderr
    if [[ -n $TIMEOUT_CMD ]]; then
        if output=$($TIMEOUT_CMD 1 $SCRIPT $args 2>&1); then
            cmd_succeeded=true
        else
            cmd_succeeded=false
        fi
    else
        # No timeout available, run without it
        if output=$($SCRIPT $args 2>&1); then
            cmd_succeeded=true
        else
            cmd_succeeded=false
        fi
    fi
    
    if [[ $cmd_succeeded == true ]]; then
        # Command succeeded
        if [[ $should_fail == "yes" ]]; then
            echo -e "${RED}FAIL${NC} - Should have rejected '$args'"
            return 1
        else
            echo -e "${GREEN}PASS${NC} - Correctly accepted"
            return 0
        fi
    else
        # Command failed
        if [[ $output == *"must be a positive integer"* ]]; then
            if [[ $should_fail == "yes" ]]; then
                echo -e "${GREEN}PASS${NC} - Correctly rejected with validation error"
                return 0
            else
                echo -e "${RED}FAIL${NC} - Incorrectly rejected valid input"
                return 1
            fi
        else
            # Failed for other reason
            if [[ $should_fail == "yes" ]]; then
                echo -e "${RED}UNCLEAR${NC} - Failed but not with validation error"
                echo "  Output: ${output:0:100}"
                return 1
            else
                echo -e "${GREEN}PASS${NC} - Validation passed (other error occurred)"
                return 0
            fi
        fi
    fi
}

# Test invalid inputs (should fail validation)
test_validation "negative minutes (-m -5)" "-m -5" "yes"
test_validation "zero minutes (-m 0)" "-m 0" "yes"
test_validation "decimal minutes (-m 3.5)" "-m 3.5" "yes"
test_validation "non-numeric minutes (-m abc)" "-m abc" "yes"
test_validation "leading zero (-m 05)" "-m 05" "yes"

test_validation "negative hours (-H -2)" "-H -2" "yes"
test_validation "zero hours (-H 0)" "-H 0" "yes"
test_validation "decimal hours (-H 1.5)" "-H 1.5" "yes"

test_validation "negative days (-d -1)" "-d -1" "yes"
test_validation "zero days (-d 0)" "-d 0" "yes"
test_validation "decimal days (-d 2.5)" "-d 2.5" "yes"

# Test valid inputs (should pass validation)
test_validation "valid minutes (-m 1)" "-m 1" "no"
test_validation "valid hours (-H 1)" "-H 1" "no"
test_validation "valid days (-d 1)" "-d 1" "no"
test_validation "large number (-m 60)" "-m 60" "no"

echo ""
echo "=============================="
echo "Validation testing complete!"
