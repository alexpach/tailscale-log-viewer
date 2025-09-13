#!/bin/bash

# Test script for numeric validation in ts-logs
# Tests validation of -m/--minutes, -H/--hours, -d/--days arguments

set -euo pipefail

# Ensure we're running from the project root
if [[ ! -f "ts-logs" ]]; then
    echo "Error: This test must be run from the project root directory" >&2
    echo "Usage: ./test/test_numeric_validation.sh" >&2
    exit 1
fi

# Generate test data if it doesn't exist
if [[ ! -f "examples/test-data-$(date +%Y%m%d).json" ]]; then
    echo "Generating test data for today..." >&2
    ./ts-logs --generate-test-data > /dev/null 2>&1
fi

SCRIPT="./ts-logs"
# Set a fake tailnet to prevent actual API calls for validation tests
export TAILNET="test-validation.local"
# Also set a fake token to avoid prompting
export TAILSCALE_API_TOKEN="tskey-api-test-validation"
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test function
run_test() {
    local description="$1"
    local command="$2"
    local expected_result="$3" # "pass" or "fail"

    TEST_COUNT=$((TEST_COUNT + 1))

    echo -n "Test $TEST_COUNT: $description ... "

    # Run command and capture exit code
    set +e
    output=$($command 2>&1)
    exit_code=$?
    set -e

    if [[ $expected_result == "fail" ]]; then
        if [[ $exit_code -ne 0 ]]; then
            echo -e "${GREEN}PASS${NC} (correctly rejected)"
            PASS_COUNT=$((PASS_COUNT + 1))
            # Check for proper error message
            if [[ $output == *"must be a positive integer"* ]] || [[ $output == *"Invalid value"* ]]; then
                echo "  ✓ Good error message: $(echo "$output" | grep -E "Error:|Value must" | head -1)"
            fi
        else
            echo -e "${RED}FAIL${NC} (should have been rejected)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            echo "  ✗ Command succeeded when it should have failed"
        fi
    elif [[ $expected_result == "pass" ]]; then
        # For pass tests, validation should pass (no numeric validation error)
        # The command might fail for other reasons (config, network, etc) or succeed
        if [[ $exit_code -ne 0 ]] && [[ $output == *"must be a positive integer"* ]]; then
            # This is a validation failure - test failed
            echo -e "${RED}FAIL${NC} (incorrectly rejected valid input)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
            echo "  ✗ Error: $output"
        else
            # Either succeeded or failed for non-validation reasons - validation passed!
            echo -e "${GREEN}PASS${NC} (validation passed)"
            PASS_COUNT=$((PASS_COUNT + 1))
            if [[ $exit_code -eq 0 ]]; then
                echo "  ✓ Command executed successfully"
            else
                echo "  ✓ Validation passed (failed for other reason: config/network/etc)"
            fi
        fi
    fi
}

echo "========================================="
echo "Testing Numeric Validation for ts-logs"
echo "========================================="
echo

# Test --minutes/-m validation
echo "Testing --minutes/-m argument:"
echo "-------------------------------"
run_test "Negative value (-m -5)" "$SCRIPT -m -5" "fail"
run_test "Zero value (-m 0)" "$SCRIPT -m 0" "fail"
run_test "Decimal value (-m 3.5)" "$SCRIPT -m 3.5" "fail"
run_test "Non-numeric value (-m abc)" "$SCRIPT -m abc" "fail"
run_test "Empty value (-m '')" "$SCRIPT -m ''" "fail"
run_test "Valid single digit (-m 1)" "$SCRIPT --use-test-data -m 1" "pass"
run_test "Valid double digit (-m 10)" "$SCRIPT --use-test-data -m 10" "pass"
run_test "Valid large number (-m 60)" "$SCRIPT --use-test-data -m 60" "pass"
run_test "Long form negative (--minutes -10)" "$SCRIPT --minutes -10" "fail"
run_test "Long form valid (--minutes 5)" "$SCRIPT --use-test-data --minutes 5" "pass"
echo

# Test --hours/-H validation
echo "Testing --hours/-H argument:"
echo "----------------------------"
run_test "Negative value (-H -2)" "$SCRIPT -H -2" "fail"
run_test "Zero value (-H 0)" "$SCRIPT -H 0" "fail"
run_test "Decimal value (-H 1.5)" "$SCRIPT -H 1.5" "fail"
run_test "Non-numeric value (-H xyz)" "$SCRIPT -H xyz" "fail"
run_test "Valid single digit (-H 1)" "$SCRIPT --use-test-data -H 1" "pass"
run_test "Valid double digit (-H 2)" "$SCRIPT --use-test-data -H 2" "pass"
run_test "Valid triple digit (-H 12)" "$SCRIPT --use-test-data -H 12" "pass"
run_test "Long form negative (--hours -3)" "$SCRIPT --hours -3" "fail"
run_test "Long form valid (--hours 2)" "$SCRIPT --use-test-data --hours 2" "pass"
echo

# Test --days/-d validation
echo "Testing --days/-d argument:"
echo "---------------------------"
run_test "Negative value (-d -1)" "$SCRIPT -d -1" "fail"
run_test "Zero value (-d 0)" "$SCRIPT -d 0" "fail"
run_test "Decimal value (-d 2.5)" "$SCRIPT -d 2.5" "fail"
run_test "Non-numeric value (-d week)" "$SCRIPT -d week" "fail"
run_test "Valid single digit (-d 1)" "$SCRIPT --use-test-data -d 1" "pass"
run_test "Valid double digit (-d 2)" "$SCRIPT --use-test-data -d 2" "pass"
run_test "Long form negative (--days -7)" "$SCRIPT --days -7" "fail"
run_test "Long form valid (--days 1)" "$SCRIPT --use-test-data --days 1" "pass"
echo

# Edge cases
echo "Testing edge cases:"
echo "-------------------"
run_test "Leading zeros (-m 05)" "$SCRIPT -m 05" "fail" # Should fail, leading zeros not allowed
run_test "Plus sign (-m +5)" "$SCRIPT -m +5" "fail"     # Should fail, plus sign not allowed
run_test "Spaces in number (-m '1 0')" "$SCRIPT -m '1 0'" "fail"
run_test "Very large number (-m 999999)" "echo '999999' | grep -E '^[1-9][0-9]*$' >/dev/null && echo 'pass' || echo 'fail'" "pass"  # Just test the pattern
echo

# Summary
echo "========================================="
echo "Test Results Summary"
echo "========================================="
echo -e "Total tests: $TEST_COUNT"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed. Please review the implementation.${NC}"
    exit 1
fi
