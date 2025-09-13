#!/bin/bash

# Test script for CSV output format
set -euo pipefail

# Ensure we're running from the project root
if [[ ! -f "ts-logs" ]]; then
    echo "Error: This test must be run from the project root directory" >&2
    echo "Usage: ./test/test_csv_output.sh" >&2
    exit 1
fi

# Source .env if it exists
if [[ -f .env ]]; then
    source .env
fi

SCRIPT="./ts-logs"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Testing CSV output format..."
echo "============================"

# Test 1: Check if CSV format is accepted
echo -n "Test 1: CSV format is accepted... "
# Capture output first, then check for header (ignore exit code of script)
output=$($SCRIPT -m 5 -f csv 2>/dev/null || true)
if echo "$output" | grep -q "Time,Source IP"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  CSV header not found"
fi

# Test 2: Check CSV structure (should have 9 columns)
echo -n "Test 2: CSV has correct number of columns... "
header=$($SCRIPT -m 5 -f csv 2>/dev/null | grep "Time,Source IP" | head -1)
column_count=$(echo "$header" | tr ',' '\n' | wc -l | tr -d ' ')
if [[ $column_count == "9" ]]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  Expected 9 columns, got $column_count"
fi

# Test 3: Check that data rows have consistent columns
echo -n "Test 3: Data rows have consistent columns... "
output=$($SCRIPT -m 5 -f csv 2>/dev/null | grep -v "Fetching" | tail -n +2 | head -5)
all_good=true
while IFS= read -r line; do
    col_count=$(echo "$line" | tr ',' '\n' | wc -l | tr -d ' ')
    if [[ $col_count != "9" ]]; then
        all_good=false
        echo -e "${RED}FAIL${NC}"
        echo "  Row has $col_count columns: $line"
        break
    fi
done <<<"$output"
if [[ $all_good == true ]]; then
    echo -e "${GREEN}PASS${NC}"
fi

# Test 4: CSV format works with filters
echo -n "Test 4: CSV format works with traffic type filter... "
# Capture output first, then check for header (ignore exit code of script)
output=$($SCRIPT -m 5 -t virtual -f csv 2>/dev/null || true)
if echo "$output" | grep -q "Time,Source IP"; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    echo "  CSV format failed with -t filter"
fi

# Test 5: CSV can be redirected to file
echo -n "Test 5: CSV output can be saved to file... "
temp_file=$(mktemp)
if $SCRIPT -m 5 -f csv >"$temp_file" 2>/dev/null; then
    if [[ -s $temp_file ]] && grep -q "Time,Source IP" "$temp_file"; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        echo "  File is empty or doesn't contain CSV header"
    fi
else
    echo -e "${RED}FAIL${NC}"
    echo "  Failed to redirect to file"
fi
rm -f "$temp_file"

echo
echo "============================"
echo "CSV output tests complete!"
