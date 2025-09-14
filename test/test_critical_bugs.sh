#!/bin/bash

# Test script for critical bugs
# 1. IPv6 address escaping in filters
# 2. False positive filter matching
# 3. Token exposure in debug mode

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR" || exit 1

echo "Testing Critical Bugs in ts-logs"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing: $test_name... "

    # Run the test command
    result=$(eval "$test_command" 2>&1)

    if [[ "$expected_result" == "SHOULD_FAIL" ]]; then
        if [[ $? -ne 0 ]]; then
            echo -e "${GREEN}PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}FAILED${NC} - Command should have failed but succeeded"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    elif [[ "$expected_result" == "NO_TOKEN" ]]; then
        # Check that output doesn't contain the token
        if echo "$result" | grep -q "tskey-api"; then
            echo -e "${RED}FAILED${NC} - Token exposed in output!"
            echo "Output contains token: $result" | head -3
            TESTS_FAILED=$((TESTS_FAILED + 1))
        else
            echo -e "${GREEN}PASSED${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        fi
    elif echo "$result" | grep -q "$expected_result"; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        echo "Expected: $expected_result"
        echo "Got: $result" | head -3
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Generate test data if needed
if [[ ! -f "examples/test-data-$(date +%Y%m%d).json" ]]; then
    echo "Generating test data..."
    ./ts-logs --generate-test-data >/dev/null 2>&1
fi

echo ""
echo "Test 1: IPv6 Address Filtering with Special Characters"
echo "--------------------------------------------------------"

# Test IPv6 addresses with brackets
echo "Testing IPv6 address with brackets in filter..."

# Create a test with IPv6 addresses in brackets
test_ipv6_filter() {
    # This should handle IPv6 addresses like [fd7a:115c:a1e0::1234] properly
    ./ts-logs --use-test-data -m 5 -S "[fd7a:115c:a1e0::1234]" 2>&1 | grep -c "Error"
}

# The current implementation might fail with jq parse errors for brackets
run_test "IPv6 with brackets" "test_ipv6_filter" "0"

# Test IPv6 without brackets (should work)
run_test "IPv6 without brackets" "./ts-logs --use-test-data -m 5 -S 'fd7a:115c:a1e0::1234' 2>&1 | grep -c 'Filtering criteria'" "1"

echo ""
echo "Test 2: Filter Matching - False Positives"
echo "------------------------------------------"

# Test partial matching issues
echo "Testing filter precision..."

# Current implementation uses 'contains' which causes false positives
# e.g., filtering for "10.0.0.1" would also match "10.0.0.10", "10.0.0.100", "210.0.0.1"

# Create test for exact matching
test_exact_match() {
    # Filter for a specific IP that should not match similar IPs
    ./ts-logs --use-test-data -m 5 -S "10.0.0.1" -f raw 2>/dev/null | jq -r '.logs[].virtualTraffic[]?.src' | grep -E "^10\.0\.0\.1$|^10\.0\.0\.10$" | sort -u
}

echo "Current 'contains' matching (may show false positives):"
test_exact_match

echo ""
echo "Test 3: Debug Mode Token Redaction"
echo "-----------------------------------"

# Set a test token for testing (won't work with real API)
export TAILSCALE_API_TOKEN="tskey-api-test-token-12345"
export TAILNET="test.example.com"

# Test debug mode with potential token exposure
echo "Testing debug mode for token exposure..."

# Run with debug mode and check if token appears in output
run_test "Debug mode token safety" "./ts-logs --debug --use-test-data -m 1 2>&1" "NO_TOKEN"

# Test with verbose curl output (if implemented)
echo ""
echo "Checking for token in error messages..."
# Force an error to see if token is exposed
unset TAILSCALE_API_TOKEN
run_test "Error message token safety" "./ts-logs -m 1 2>&1" "NO_TOKEN"

# Restore token
export TAILSCALE_API_TOKEN="tskey-api-test-token-12345"

echo ""
echo "Test 4: Special Characters in Filter Values"
echo "--------------------------------------------"

# Test various special characters that might break jq
test_special_chars() {
    local char="$1"
    ./ts-logs --use-test-data -m 5 -S "$char" 2>&1 | grep -c "jq: error"
}

echo "Testing special characters that might break jq parsing..."
for char in '[]' '{}' '"test"' "'test'" '$test' '*' '?' '|' '&' ';'; do
    result=$(test_special_chars "$char")
    if [[ $result -gt 0 ]]; then
        echo -e "  Character '$char': ${RED}Causes jq error${NC}"
    else
        echo -e "  Character '$char': ${GREEN}Handled correctly${NC}"
    fi
done

echo ""
echo "Test 5: Exclusion Filter Issues"
echo "--------------------------------"

# Test exclusion filters with special characters
run_test "Exclusion with IPv6" "./ts-logs --use-test-data -m 5 --exclude-src 'fd7a:115c:a1e0::1234' 2>&1 | grep -c 'Error'" "0"

echo ""
echo "======================================="
echo "Test Summary:"
echo "  Tests Run: $TESTS_RUN"
echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${YELLOW}Critical bugs detected that need fixing!${NC}"
    exit 1
else
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
fi