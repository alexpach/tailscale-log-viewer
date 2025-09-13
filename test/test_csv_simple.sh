#!/bin/bash

# Simple test to verify CSV format works
echo "Testing CSV output format (simple test)..."

# Run from parent directory to ensure .env is found
cd "$(dirname "$0")/.." || exit 1

# Test CSV output
if ./ts-logs -m 5 -f csv 2>/dev/null | head -1 | grep -q "Time,Source IP"; then
    echo "✅ CSV format works!"
    ./ts-logs -m 5 -f csv 2>/dev/null | head -5
else
    echo "❌ CSV format failed"
    exit 1
fi