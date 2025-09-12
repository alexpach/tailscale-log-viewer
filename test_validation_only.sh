#!/bin/bash

# Quick validation test - just test if validation rejects bad inputs
# We'll use a fake tailnet to prevent actual API calls

set -euo pipefail

SCRIPT="./ts-logs"
export TAILNET="test.com"  # Set a test tailnet to avoid config error

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
    if output=$(timeout 1 $SCRIPT $args 2>&1); then
        # Command succeeded
        if [[ "$should_fail" == "yes" ]]; then
            echo -e "${RED}FAIL${NC} - Should have rejected '$args'"
            return 1
        else
            echo -e "${GREEN}PASS${NC} - Correctly accepted"
            return 0
        fi
    else
        # Command failed
        if [[ "$output" == *"must be a positive integer"* ]]; then
            if [[ "$should_fail" == "yes" ]]; then
                echo -e "${GREEN}PASS${NC} - Correctly rejected with validation error"
                return 0
            else
                echo -e "${RED}FAIL${NC} - Incorrectly rejected valid input"
                return 1
            fi
        else
            # Failed for other reason
            if [[ "$should_fail" == "yes" ]]; then
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
test_validation "valid minutes (-m 5)" "-m 5" "no"
test_validation "valid hours (-H 24)" "-H 24" "no"
test_validation "valid days (-d 30)" "-d 30" "no"
test_validation "large number (-m 999)" "-m 999" "no"

echo ""
echo "=============================="
echo "Validation testing complete!"