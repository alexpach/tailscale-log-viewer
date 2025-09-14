#!/bin/bash

# Test script to verify API token security improvements

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR" || exit 1

echo "Testing API Token Security"
echo "==========================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

# Test 1: Verify token is not exposed in process listing
echo "Test 1: Process listing exposure check"
echo "---------------------------------------"

# Set a test token
export TAILSCALE_API_TOKEN="tskey-api-secret-token-12345"

# Run the script in background and check if token appears in ps output
./ts-logs --use-test-data -m 5 >/dev/null 2>&1 &
PID=$!
sleep 0.1

# Check if token appears in process listing
if ps aux | grep -v grep | grep "$PID" | grep -q "tskey-api-secret"; then
    echo -e "${RED}FAIL${NC}: Token visible in process listing!"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    echo -e "${GREEN}PASS${NC}: Token not visible in process listing"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Clean up background process
kill $PID 2>/dev/null || true
wait $PID 2>/dev/null || true

echo ""

# Test 2: Verify token validation
echo "Test 2: Token validation"
echo "------------------------"

# Test with invalid token format (without test data mode)
export TAILSCALE_API_TOKEN="invalid-token-format"
export TAILNET="test.example.com"

# Use gtimeout on macOS, timeout on Linux
if command -v gtimeout >/dev/null 2>&1; then
    output=$(gtimeout 1 ./ts-logs -m 5 2>&1 || true)
elif command -v timeout >/dev/null 2>&1; then
    output=$(timeout 1 ./ts-logs -m 5 2>&1 || true)
else
    # Fallback without timeout
    output=$(./ts-logs -m 5 2>&1 &)
    sleep 1
    kill $! 2>/dev/null || true
fi

if echo "$output" | grep -q "Invalid API token format"; then
    echo -e "${GREEN}PASS${NC}: Invalid token format detected"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}FAIL${NC}: Invalid token format not detected"
    echo "  Note: Test data mode skips validation"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Test with valid token format
export TAILSCALE_API_TOKEN="tskey-api-valid-12345"
output=$(./ts-logs --use-test-data -m 5 -f raw 2>/dev/null | head -1)

if [[ "$output" == "{" ]]; then
    echo -e "${GREEN}PASS${NC}: Valid token format accepted"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}FAIL${NC}: Valid token not working"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""

# Test 3: Verify no echo in shell trace mode
echo "Test 3: Shell trace mode security"
echo "----------------------------------"

export TAILSCALE_API_TOKEN="tskey-api-trace-test-12345"

# Run with shell tracing enabled (bash -x)
trace_output=$(bash -x ./ts-logs --use-test-data -m 5 -f raw 2>&1 | head -50)

# Check if token appears in trace output
if echo "$trace_output" | grep -q "tskey-api-trace-test"; then
    echo -e "${YELLOW}WARNING${NC}: Token might be visible in trace mode"
    echo "  Consider disabling sensitive operations when set -x is active"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    echo -e "${GREEN}PASS${NC}: Token not visible in trace output"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

echo ""

# Test 4: Verify global variable approach
echo "Test 4: Global variable implementation"
echo "---------------------------------------"

# Check if the old get_api_token function is gone
if grep -q "^get_api_token()" ts-logs; then
    echo -e "${RED}FAIL${NC}: Old get_api_token function still exists"
    TESTS_FAILED=$((TESTS_FAILED + 1))
else
    echo -e "${GREEN}PASS${NC}: Old function removed"
    TESTS_PASSED=$((TESTS_PASSED + 1))
fi

# Check if new init_api_token function exists
if grep -q "^init_api_token()" ts-logs; then
    echo -e "${GREEN}PASS${NC}: New init_api_token function exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}FAIL${NC}: New function not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Check if API_TOKEN_CACHED is used
if grep -q "API_TOKEN_CACHED" ts-logs; then
    echo -e "${GREEN}PASS${NC}: Global variable API_TOKEN_CACHED is used"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}FAIL${NC}: Global variable not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

echo ""
echo "======================================="
echo "Test Summary:"
echo "  Tests Passed: $TESTS_PASSED"
echo "  Tests Failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "\n${YELLOW}Some security improvements needed${NC}"
    exit 1
else
    echo -e "\n${GREEN}All security tests passed!${NC}"
    exit 0
fi