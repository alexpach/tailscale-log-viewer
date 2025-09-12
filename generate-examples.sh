#!/usr/bin/env bash

# generate-examples.sh
# Script to generate example logs for Tailscale logging

set -euo pipefail

EXAMPLES_DIR="examples"

 ./ts-logs -m 1 -f table > $EXAMPLES_DIR/log-table.txt
 ./ts-logs -m 1 -f compact > $EXAMPLES_DIR/log-compact.txt
 ./ts-logs -m 1 -f csv > $EXAMPLES_DIR/log-csv.csv
 ./ts-logs -m 1 -f json > $EXAMPLES_DIR/log-json.json
 ./ts-logs -m 1 -f raw > $EXAMPLES_DIR/log-raw.json

echo "Example logs generated in $EXAMPLES_DIR/"
ls -al $EXAMPLES_DIR/