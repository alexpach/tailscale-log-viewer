#!/bin/bash

# Test exact matching implementation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_DIR" || exit 1

# Create test data
cat > examples/test-exact.json << 'EOF'
{
  "logs": [
    {
      "nodeId": "node1",
      "logged": "2025-01-13T10:00:00Z",
      "virtualTraffic": [
        {"src": "10.0.0.1", "dst": "192.168.1.1", "proto": 6, "txBytes": 100},
        {"src": "10.0.0.10", "dst": "192.168.1.1", "proto": 6, "txBytes": 200},
        {"src": "210.0.0.1", "dst": "192.168.1.1", "proto": 6, "txBytes": 300}
      ]
    }
  ],
  "devices": []
}
EOF

echo "Testing exact IP matching..."
echo "============================="
echo ""

# Test 1: Filter for exact IP "10.0.0.1"
echo "Test 1: Filtering for '10.0.0.1' (should match only 10.0.0.1):"
result=$(./ts-logs --use-test-data -S "10.0.0.1" -f raw < examples/test-exact.json 2>/dev/null | jq -r '.logs[].virtualTraffic[]?.src' 2>/dev/null | sort -u)

if [[ -z "$result" ]]; then
    echo "No matches found (checking if jq filter is working...)"

    # Debug: Show the actual filter being applied
    echo ""
    echo "Debug: Testing jq filter directly..."

    # Try to see what the filter looks like
    ./ts-logs --use-test-data -S "10.0.0.1" --debug -f raw < examples/test-exact.json 2>&1 | grep -E "filter|jq" | head -10
else
    echo "Matched IPs: $result"

    if [[ "$result" == "10.0.0.1" ]]; then
        echo "✓ EXACT MATCH WORKING!"
    else
        echo "✗ FALSE POSITIVES DETECTED"
        echo "  Expected: 10.0.0.1"
        echo "  Got: $result"
    fi
fi

echo ""
echo "Test 2: Without any filter (baseline):"
result=$(cat examples/test-exact.json | jq -r '.logs[].virtualTraffic[]?.src' | sort -u)
echo "All IPs in test data: $result"

# Clean up
rm -f examples/test-exact.json