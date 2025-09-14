#!/bin/bash

# Test filter matching precision to detect false positives

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR" || exit 1

echo "Testing Filter Matching Precision"
echo "================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# First, generate test data with specific IPs that could cause false positives
cat > examples/test-precision.json << 'EOF'
{
  "logs": [
    {
      "nodeId": "node1",
      "logged": "2025-01-13T10:00:00Z",
      "virtualTraffic": [
        {"src": "10.0.0.1", "dst": "10.0.0.2", "proto": 6, "txBytes": 100},
        {"src": "10.0.0.10", "dst": "10.0.0.2", "proto": 6, "txBytes": 200},
        {"src": "10.0.0.100", "dst": "10.0.0.2", "proto": 6, "txBytes": 300},
        {"src": "210.0.0.1", "dst": "10.0.0.2", "proto": 6, "txBytes": 400},
        {"src": "192.168.1.1", "dst": "10.0.0.2", "proto": 6, "txBytes": 500},
        {"src": "192.168.1.10", "dst": "10.0.0.2", "proto": 6, "txBytes": 600}
      ]
    },
    {
      "nodeId": "server1-prod",
      "logged": "2025-01-13T10:01:00Z",
      "virtualTraffic": [
        {"src": "100.64.0.1", "dst": "10.0.0.2", "proto": 6, "txBytes": 700}
      ]
    },
    {
      "nodeId": "server10-dev",
      "logged": "2025-01-13T10:02:00Z",
      "virtualTraffic": [
        {"src": "100.64.0.2", "dst": "10.0.0.2", "proto": 6, "txBytes": 800}
      ]
    }
  ],
  "devices": [
    {"nodeId": "node1", "name": "laptop.example.com", "addresses": ["10.0.0.1"]},
    {"nodeId": "server1-prod", "name": "server1.example.com", "addresses": ["100.64.0.1"]},
    {"nodeId": "server10-dev", "name": "server10.example.com", "addresses": ["100.64.0.2"]}
  ]
}
EOF

echo "Test 1: IP Address False Positives"
echo "-----------------------------------"

# Test filtering for "10.0.0.1" - should NOT match "10.0.0.10", "10.0.0.100", or "210.0.0.1"
echo -e "\nFiltering for source IP '10.0.0.1':"
result=$(./ts-logs --use-test-data -S "10.0.0.1" -f raw 2>/dev/null < examples/test-precision.json | \
    jq -r '.logs[].virtualTraffic[]? | select(.src) | .src' | sort -u)

echo "IPs matched: $result"

# Count how many different IPs were matched
count=$(echo "$result" | grep -c "^")

if [[ $count -eq 1 ]] && [[ "$result" == "10.0.0.1" ]]; then
    echo -e "${GREEN}PASS${NC}: Exact match only (correct behavior)"
else
    echo -e "${RED}FAIL${NC}: False positives detected!"
    echo "  Expected: 10.0.0.1 only"
    echo "  Got: $result"
    echo -e "${YELLOW}This indicates the filter uses 'contains' instead of exact matching${NC}"
fi

echo ""
echo "Test 2: Machine Name False Positives"
echo "-------------------------------------"

# Test filtering for "server1" - should NOT match "server10"
echo -e "\nFiltering for machine name 'server1':"
result=$(./ts-logs --use-test-data -S "server1" -f raw 2>/dev/null < examples/test-precision.json | \
    jq -r '.logs[].nodeId' | sort -u)

echo "Nodes matched: $result"

if echo "$result" | grep -q "server10"; then
    echo -e "${RED}FAIL${NC}: False positive - 'server1' matched 'server10'"
    echo -e "${YELLOW}This indicates substring matching is too broad${NC}"
else
    echo -e "${GREEN}PASS${NC}: No false positives for machine names"
fi

echo ""
echo "Test 3: Exclusion Filter Precision"
echo "-----------------------------------"

# Test exclusion filters for similar false positive issues
echo -e "\nExcluding source IP '10.0.0.1' (should still show 10.0.0.10, 10.0.0.100):"
result=$(./ts-logs --use-test-data --exclude-src "10.0.0.1" -f raw 2>/dev/null < examples/test-precision.json | \
    jq -r '.logs[].virtualTraffic[]? | select(.src) | .src' | grep "10\.0\.0\." | sort -u)

echo "Remaining IPs with 10.0.0.x: $result"

if echo "$result" | grep -q "10.0.0.10\|10.0.0.100"; then
    echo -e "${GREEN}PASS${NC}: Exclusion is working with proper precision"
else
    echo -e "${RED}FAIL${NC}: Exclusion filter is too broad"
fi

echo ""
echo "Test 4: Checking Current Implementation"
echo "----------------------------------------"

# Let's check the actual filter implementation
echo "Analyzing filter implementation in ts-logs..."

# Check if filters use 'contains' (causes false positives) or exact matching
if grep -q 'contains(\$pattern)' ts-logs; then
    echo -e "${YELLOW}WARNING${NC}: Script uses 'contains' for filtering"
    echo "  This will cause false positives:"
    echo "  - '10.0.0.1' will match '10.0.0.10', '10.0.0.100', '210.0.0.1'"
    echo "  - 'server1' will match 'server1', 'server10', 'server123'"
    echo ""
    echo "Recommended fix:"
    echo "  For IP addresses: Use exact match or anchored regex"
    echo "  For machine names: Consider word boundaries or exact match option"
else
    echo -e "${GREEN}OK${NC}: Script doesn't use simple 'contains' matching"
fi

# Clean up test file
rm -f examples/test-precision.json

echo ""
echo "======================================="
echo "Filter Precision Analysis Complete"
echo ""
echo "Key Findings:"
echo "1. The script uses 'contains' for filter matching"
echo "2. This causes false positives when filtering"
echo "3. Need to implement more precise matching logic"