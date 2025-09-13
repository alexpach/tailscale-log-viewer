#!/bin/bash

# Test data generator for ts-logs utility
# Generates sample JSON log data for testing without API access

set -euo pipefail

# Default values
NUM_LOGS=10
TRAFFIC_TYPES="virtual,subnet,exit,physical"
OUTPUT_FILE=""

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Generate test data for ts-logs utility testing.

Options:
    -n NUM      Number of log entries to generate (default: 10)
    -t TYPES    Comma-separated traffic types (default: virtual,subnet,exit,physical)
    -o FILE     Output file (default: stdout)
    -h          Show this help

Examples:
    $0 -n 50                           # Generate 50 log entries
    $0 -n 100 -t virtual,exit          # Generate 100 entries with only virtual and exit traffic
    $0 -n 20 -o test_data.json         # Generate 20 entries and save to file
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n)
            NUM_LOGS="$2"
            shift 2
            ;;
        -t)
            TRAFFIC_TYPES="$2"
            shift 2
            ;;
        -o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Error: Unknown option $1" >&2
            show_help >&2
            exit 1
            ;;
    esac
done

# Sample IPs and machine names
TAILSCALE_IPS=("100.64.0.1" "100.64.0.2" "100.64.0.3" "100.64.0.4" "100.64.0.5")
MACHINE_NAMES=("laptop-work" "server-prod" "desktop-home" "phone-mobile" "tablet-dev")
EXTERNAL_IPS=("8.8.8.8" "1.1.1.1" "93.184.216.34" "192.168.1.1" "10.0.0.1")
SUBNET_IPS=("172.17.0.1" "172.18.0.1" "10.123.123.13" "10.123.123.29" "192.168.100.1")
IPV6_ADDRESSES=("fd7a:115c:a1e0::1" "fd7a:115c:a1e0::2" "2001:db8::1" "2001:db8::2")
NODE_IDS=("nodeA123" "nodeB456" "nodeC789" "nodeD012" "nodeE345")
PROTOCOLS=("TCP" "UDP" "ICMP")
PORTS=(22 80 443 3389 5432 8080 9100 53 67 68 123)

# Generate random timestamp
generate_timestamp() {
    local offset=$((RANDOM % 3600))  # Random offset within last hour
    if [[ "$(uname)" == "Darwin" ]]; then
        date -u -v-${offset}S "+%Y-%m-%dT%H:%M:%SZ"
    else
        date -u -d "$offset seconds ago" "+%Y-%m-%dT%H:%M:%SZ"
    fi
}

# Generate random IP with port
generate_ip_port() {
    local ip_type=$1
    local ip port
    
    case $ip_type in
        tailscale)
            ip="${TAILSCALE_IPS[$((RANDOM % ${#TAILSCALE_IPS[@]}))]}"
            ;;
        external)
            ip="${EXTERNAL_IPS[$((RANDOM % ${#EXTERNAL_IPS[@]}))]}"
            ;;
        subnet)
            ip="${SUBNET_IPS[$((RANDOM % ${#SUBNET_IPS[@]}))]}"
            ;;
        ipv6)
            ip="${IPV6_ADDRESSES[$((RANDOM % ${#IPV6_ADDRESSES[@]}))]}"
            ;;
        *)
            ip="127.0.0.1"
            ;;
    esac
    
    port="${PORTS[$((RANDOM % ${#PORTS[@]}))]}"
    
    if [[ "$ip" =~ : ]]; then
        echo "[${ip}]:${port}"
    else
        echo "${ip}:${port}"
    fi
}

# Generate traffic entry
generate_traffic_entry() {
    local traffic_type=$1
    local src dst proto txBytes rxBytes
    
    case $traffic_type in
        virtual)
            src=$(generate_ip_port tailscale)
            dst=$(generate_ip_port tailscale)
            ;;
        subnet)
            if [[ $((RANDOM % 2)) -eq 0 ]]; then
                src=$(generate_ip_port tailscale)
                dst=$(generate_ip_port subnet)
            else
                src=$(generate_ip_port subnet)
                dst=$(generate_ip_port tailscale)
            fi
            ;;
        exit)
            src=$(generate_ip_port tailscale)
            dst=$(generate_ip_port external)
            ;;
        physical)
            src="${NODE_IDS[$((RANDOM % ${#NODE_IDS[@]}))]}"
            dst=$(generate_ip_port external)
            ;;
    esac
    
    proto="${PROTOCOLS[$((RANDOM % ${#PROTOCOLS[@]}))]}"
    txBytes=$((RANDOM % 100000))
    rxBytes=$((RANDOM % 100000))
    
    cat << EOF
            {
                "src": "$src",
                "dst": "$dst",
                "proto": "$proto",
                "txBytes": $txBytes,
                "rxBytes": $rxBytes
            }
EOF
}

# Generate log entry
generate_log_entry() {
    local timestamp=$(generate_timestamp)
    local traffic_array=(${TRAFFIC_TYPES//,/ })
    local entries=""
    
    echo "    {"
    echo "        \"start\": \"$timestamp\","
    echo "        \"end\": \"$timestamp\","
    echo "        \"nodeId\": \"${NODE_IDS[$((RANDOM % ${#NODE_IDS[@]}))]}}\","
    
    # Generate traffic for each type if randomly selected
    for traffic_type in "${traffic_array[@]}"; do
        if [[ $((RANDOM % 3)) -gt 0 ]]; then  # 66% chance to include each type
            case $traffic_type in
                virtual)
                    echo "        \"virtualTraffic\": ["
                    generate_traffic_entry virtual
                    echo "        ],"
                    ;;
                subnet)
                    echo "        \"subnetTraffic\": ["
                    generate_traffic_entry subnet
                    echo "        ],"
                    ;;
                exit)
                    echo "        \"exitTraffic\": ["
                    generate_traffic_entry exit
                    echo "        ],"
                    ;;
                physical)
                    echo "        \"physicalTraffic\": ["
                    generate_traffic_entry physical
                    echo "        ],"
                    ;;
            esac
        fi
    done | sed '$ s/,$//'  # Remove trailing comma from last item
    
    echo "    }"
}

# Generate devices data
generate_devices() {
    cat << EOF
{
    "devices": [
EOF
    
    for i in "${!TAILSCALE_IPS[@]}"; do
        cat << EOF
        {
            "id": "${NODE_IDS[$i]}",
            "name": "${MACHINE_NAMES[$i]}.tail43508.ts.net",
            "hostname": "${MACHINE_NAMES[$i]}",
            "addresses": ["${TAILSCALE_IPS[$i]}/32"],
            "lastSeen": "$(generate_timestamp)"
        }
EOF
        if [[ $i -lt $((${#TAILSCALE_IPS[@]} - 1)) ]]; then
            echo "        ,"
        fi
    done
    
    cat << EOF
    ]
}
EOF
}

# Main output generation
generate_output() {
    cat << EOF
{
    "logs": [
EOF
    
    for ((i=1; i<=NUM_LOGS; i++)); do
        generate_log_entry
        if [[ $i -lt $NUM_LOGS ]]; then
            echo "    ,"
        fi
    done
    
    cat << EOF
    ]
}
EOF
}

# Generate and output data
if [[ -n "$OUTPUT_FILE" ]]; then
    {
        echo "=== LOGS DATA ==="
        generate_output
        echo ""
        echo "=== DEVICES DATA ==="
        generate_devices
    } > "$OUTPUT_FILE"
    echo "Generated test data saved to: $OUTPUT_FILE" >&2
else
    generate_output
fi