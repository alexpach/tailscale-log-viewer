#!/bin/bash

# Simple test to verify CSV format works
echo "Testing CSV output format (simple test)..."

# Ensure we're running from the project root
if [[ ! -f "ts-logs" ]]; then
    echo "Error: This test must be run from the project root directory" >&2
    echo "Usage: ./test/test_csv_simple.sh" >&2
    exit 1
fi

# Test CSV output
if ./ts-logs -m 5 -f csv 2>/dev/null | head -1 | grep -q "Time,Source IP"; then
    echo "✅ CSV format works!"
    ./ts-logs -m 5 -f csv 2>/dev/null | head -5
else
    echo "❌ CSV format failed"
    exit 1
fi
