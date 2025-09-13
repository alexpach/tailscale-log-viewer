# Tailscale CLI Network Log Viewer

An enhanced command-line tool for fetching and analyzing Tailscale network logs with flexible filtering, multiple output formats, and intelligent machine name resolution.

## Features

### 🚀 Core Functionality
- **Real-time log streaming** - Results display as they're processed, not buffered
- **Flexible time ranges** - Minutes, hours, days, or specific time periods
- **Multiple output formats** - Detailed table view and compact summary
- **Traffic type filtering** - Virtual, subnet, exit, and physical traffic analysis
- **Source/destination filtering** - Filter by machine names, IP addresses, or node IDs

### 🔍 Enhanced Analysis
- **Machine name resolution** - Tailscale IPs (100.x.x.x) automatically resolve to readable machine names
- **Service name resolution** - Common ports display as service names (http, https, ssh, dns, etc.)
- **IPv6 support** - Full support for IPv6 addresses and proper parsing
- **Traffic flow filtering** - Filter at the individual flow level, not just log entries
- **Smart error handling** - Helpful error messages guide users to correct usage
- **Exclusion filters** - Exclude specific sources or destinations from results
- **IP masking** - Privacy mode to redact sensitive IP addresses
- **Processing statistics** - Track API performance and record counts
- **Debug mode** - Verbose logging for troubleshooting

### 📊 Output Formats
- **Table format (default)** - Detailed view with separate columns for IPs, ports, services, and byte counts
- **Compact format** - Simplified 4-column view for quick analysis
- **CSV format** - Comma-separated values for Excel/Google Sheets import
- **Enhanced summary format** - Machine-centric activity overview with aggregated statistics
- **JSON formats** - Raw and pretty-printed JSON output

## Quick Start

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/alexpach/tailscale-logging.git
   cd tailscale-logging
   ```

2. **Make executable**:
   ```bash
   chmod +x ts-logs
   ```

3. **Install dependencies**:
   ```bash
   # macOS
   brew install jq
   
   # Ubuntu/Debian
   sudo apt-get install jq
   ```

4. **Configure API access**:
   ```bash
   cp .env.example .env
   # Edit .env with your Tailscale API token and tailnet
   ```

### Configuration

Create a `.env` file with your Tailscale configuration:

```bash
TAILSCALE_API_TOKEN=tskey-api-your-actual-token-here
TAILNET=your-company.com
```

**API Token Requirements**:
- Format: `tskey-api-*` 
- Required permissions: `logs:network:read` and `devices:read`
- Generate at: [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)

## Usage

### Basic Commands

```bash
# Show help (default when no arguments)
./ts-logs

# Most common usage patterns
./ts-logs -m 5          # Last 5 minutes in detailed table format
./ts-logs -m 30 -f compact  # Last 30 minutes in compact format
./ts-logs -m 15 -s      # Last 15 minutes machine activity summary
./ts-logs -H 6 -t exit  # Exit traffic from last 6 hours
```

### Time Range Options

```bash
# Relative time ranges
./ts-logs -m 30         # Last 30 minutes
./ts-logs -H 6          # Last 6 hours  
./ts-logs -d 3          # Last 3 days

# Convenient shortcuts
./ts-logs --today       # All traffic from today
./ts-logs --yesterday   # All traffic from yesterday

# Specific time range (RFC 3339 format)
./ts-logs --since 2025-08-28T00:00:00Z --until 2025-08-28T23:59:59Z

# Advanced options
./ts-logs -m 5 --debug  # Enable debug logging
./ts-logs -m 5 --stats  # Show processing statistics
./ts-logs -m 5 --mask-ips  # Mask IP addresses for privacy
```

### Output Formats

```bash
# Detailed table format (default) - shows separate IP and port columns
./ts-logs -m 15

# Compact format - simplified 4-column view
./ts-logs -m 15 -f compact

# CSV format - export to spreadsheet
./ts-logs -m 15 -f csv > traffic.csv

# JSON output (requires jq or python3)
./ts-logs -m 15 -f json

# Raw JSON output
./ts-logs -m 15 -f raw

# Enhanced summary - machine activity overview with aggregated stats
./ts-logs -s -d 1
./ts-logs --summary -H 2
```

### Traffic Filtering

```bash
# Filter by traffic type
./ts-logs -t virtual -H 24    # Direct Tailscale-to-Tailscale traffic
./ts-logs -t subnet -H 12     # Traffic to/from subnet routes
./ts-logs -t exit -H 6        # Traffic through exit nodes
./ts-logs -t physical -H 2    # Physical network communication

# Filter by source/destination (supports machine names, IPs, node IDs)
./ts-logs --src laptop-work -H 2        # Traffic from laptop-work
./ts-logs --dst server -m 30            # Traffic to server
./ts-logs --src 100.44.1.5 -H 1         # Traffic from specific IP
./ts-logs --dst fd7a:125c:a0e0::1 -m 15 # IPv6 destination filtering
```

### Filtering and Exclusion

```bash
# Filter by source
./ts-logs -S laptop-work -m 30  # Show only traffic from laptop-work
./ts-logs -S 100.64.0.1 -H 2    # Filter by specific IP

# Filter by destination
./ts-logs -D server-prod -m 15  # Show only traffic to server-prod
./ts-logs -D 192.168.1 -H 1     # Filter by subnet prefix

# Exclude specific sources/destinations
./ts-logs --exclude-src noisy-bot -m 30  # Hide traffic from noisy-bot
./ts-logs --exclude-dst 8.8.8.8 -H 2     # Exclude DNS traffic to Google

# Combine filters and exclusions
./ts-logs -S laptop -D server --exclude-src bot -m 30
```

### Advanced Examples

```bash
# Troubleshoot exit node traffic with detailed breakdown
./ts-logs -t exit -H 6

# Monitor recent subnet activity
./ts-logs -t subnet -m 15 -f compact

# Analyze traffic with privacy mode
./ts-logs --mask-ips -m 30 -f csv > sanitized_logs.csv

# Debug with verbose output and statistics
./ts-logs --debug --stats -m 5

# Export filtered data for analysis
./ts-logs -t virtual --exclude-src bot -d 1 -f csv > virtual_traffic.csv

# Monitor DHCP and DNS activity
./ts-logs -t exit -m 30 | grep -E 'dhcp|dns'
```

## Example Output

### Enhanced Summary Format
Comprehensive machine activity overview with aggregated statistics:

```
=== Traffic Summary ===
Total log entries: 37
Unique nodes: 5
Traffic types found: exitTraffic, physicalTraffic, virtualTraffic

Machine Activity Summary:
Machine Name                    | Entries |   TX Bytes |   RX Bytes | Virtual |  Subnet |    Exit | Physical
------------------------------- | ------- | ---------- | ---------- | ------- | ------- | ------- | --------
macbook-pro                     |      37 |   525.6 KB |     8.1 KB |    ✓    |         |         |    ✓   
mac1-home                       |      12 |    29.1 KB |    17.0 KB |    ✓    |         |    ✓    |    ✓   
toaster                         |       8 |     1.0 KB |        0 B |         |         |    ✓    |         
server-dev                      |       6 |      600 B |        0 B |         |         |    ✓    |         
100.104.19.161                  |       2 |      420 B |      156 B |         |         |    ✓    |    ✓   

Traffic Types:
  Virtual  - Direct Tailscale-to-Tailscale communication
  Subnet   - Traffic to/from subnet routes
  Exit     - Traffic through exit nodes to external internet
  Physical - Underlying physical network communication
```

### Table Format (Default)
Shows detailed traffic flows with machine name resolution and service names:

```
Filtering: Source matches 'laptop-work' (machine name, IP, or node ID)

Time     | Src IP              | SPort | Dst IP              | DPort | Type   | Proto | TxBytes | RxBytes
---------|--------------------:|------:|--------------------:|------:|--------|-------|--------:|--------:
14:32:16 | laptop-work         | dhcpc | 192.168.100.1       | dhcps | exit   | UDP   | 328     | 
14:32:20 | laptop-work         | 35832 | 105.15.190.98       | http  | exit   | TCP   | 60      | 
14:32:24 | laptop-work         | 59738 | 34.119.91.96        | https | exit   | TCP   | 180     | 
14:32:28 | laptop-work         | 49672 | 192.168.100.1       | dns   | exit   | TCP   | 120     | 

Time     | Src IP              | SPort | Dst IP              | DPort | Type   | Proto | TxBytes | RxBytes
---------|--------------------:|------:|--------------------:|------:|--------|-------|--------:|--------:
```

### Compact Format
Simplified view for quick analysis:

```
Time     | Src IP              | Dst IP              | Type
---------|--------------------:|--------------------:|--------
14:32:16 | laptop-work         | 192.168.100.1       | exit
14:32:20 | laptop-work         | 105.15.190.98       | exit
14:32:24 | laptop-work         | 34.119.91.96        | exit
```

### Service Name Resolution

Common ports are automatically resolved to readable service names:

| Port | Service | Port | Service | Port | Service |
|------|---------|------|---------|------|---------|
| 22   | ssh     | 80   | http    | 443  | https   |
| 53   | dns     | 67   | dhcps   | 68   | dhcpc   |
| 123  | ntp     | 3306 | mysql   | 5432 | pgsql   |
| 9100 | prom    | 8080 | http-alt| 587  | smtp    |

## Traffic Types Explained

### Virtual Traffic
Direct communication between Tailscale nodes within your network:
- Machine-to-machine file transfers
- SSH connections between nodes
- Application traffic between services

### Subnet Traffic
Traffic to/from subnet routes (containers, internal services):
- Docker container communication
- Kubernetes pod traffic  
- Internal service mesh traffic
- Database connections through subnets

### Exit Traffic
Traffic routed through exit nodes to external internet:
- Web browsing through exit nodes
- DHCP requests to local router
- DNS queries to external resolvers
- Software updates and downloads

### Physical Traffic
Underlying physical network communication between nodes:
- Tailscale coordination traffic
- NAT traversal and connectivity establishment
- Keep-alive and heartbeat messages

## Command-Line Options

### Time Range Options
| Short | Long | Description |
|-------|------|-------------|
| `-m N` | `--minutes N` | Last N minutes |
| `-H N` | `--hours N` | Last N hours |
| `-d N` | `--days N` | Last N days |
| | `--since TIME` | Start time (RFC 3339) |
| | `--until TIME` | End time (RFC 3339) |
| | `--today` | All traffic from today |
| | `--yesterday` | All traffic from yesterday |

### Format Options
| Short | Long | Description |
|-------|------|-------------|
| `-f FORMAT` | `--format FORMAT` | Output format: table, compact, json, raw |
| | `--summary` | Show summary statistics only |

### Filtering Options
| Short | Long | Description |
|-------|------|-------------|
| `-t TYPE` | `--traffic TYPE` | Traffic type: virtual, subnet, exit, physical |
| `-S VALUE` | `--src VALUE` | Filter by source (machine name, IP, or node ID) |
| `-D VALUE` | `--dst VALUE` | Filter by destination (machine name, IP, or node ID) |

### Other Options
| Short | Long | Description |
|-------|------|-------------|
| `-h` | `--help` | Show help message |
| | `--debug` | Enable debug mode for verbose output |
| | `--stats` | Show processing statistics |
| | `--mask-ips` | Mask IP addresses for privacy |
| | `--exclude-src VALUE` | Exclude source traffic |
| | `--exclude-dst VALUE` | Exclude destination traffic |
| | `--generate-test-data` | Generate test data for offline testing |
| | `--use-test-data` | Use cached test data instead of API |

## Test Data Support

The utility includes support for offline testing and development using test data:

### Generating Test Data
```bash
# Generate realistic test data
./ts-logs --generate-test-data
# Creates: examples/test-data-YYYYMMDD.json
```

### Using Test Data
```bash
# Use test data instead of API calls
./ts-logs --use-test-data -m 5
./ts-logs --use-test-data -H 2 -f compact
./ts-logs --use-test-data -s
```

### Benefits
- **Offline Development**: Work without network connection or API access
- **Consistent Testing**: Reproducible results for testing and debugging
- **No Rate Limits**: Avoid API rate limits during development
- **Fast Execution**: No network latency for quick iterations

## Dependencies

### Required
- **curl** - For API requests
- **bash** - Shell environment (v4.0+)

### Recommended
- **jq** - For JSON processing and formatting
- **python3** - Fallback for JSON formatting if jq unavailable

### Optional
- **gdate** - GNU date for better parsing on macOS (falls back to system date)

## API Integration

The tool integrates with Tailscale's REST API:

### Network Logs API
- **Endpoint**: `https://api.tailscale.com/api/v2/tailnet/{tailnet}/logging/network`
- **Purpose**: Fetch network flow logs
- **Limitation**: Logs available for the most recent 30 days only

### Devices API
- **Endpoint**: `https://api.tailscale.com/api/v2/tailnet/{tailnet}/devices`
- **Purpose**: Machine name resolution for readable output

## Troubleshooting

### Common Issues

**"Command not found: jq"**
```bash
# macOS
brew install jq

# Ubuntu/Debian  
sudo apt-get install jq
```

**"API request failed"**
- Verify your API token has `logs:network:read` and `devices:read` permissions
- Check your `.env` file configuration
- Ensure your tailnet name is correct

**"No logs found"**
- Tailscale only retains logs for 30 days
- Try a more recent time range
- Verify there was actually network activity during the specified period

**IPv6 addresses not displaying correctly**
- Ensure you're using the latest version of the script
- IPv6 parsing requires proper bracket notation: `[ipv6]:port`

### Debug Mode
Enable verbose output to see API requests and responses:
```bash
./ts-logs --debug -m 5
```

## Security Considerations

- **API Token Storage**: Never commit `.env` files to version control
- **Token Permissions**: Use tokens with minimal required permissions only
- **Network Security**: API tokens provide access to network logs - treat as sensitive
- **Log Retention**: Understand that network logs may contain sensitive traffic information

## Contributing

This project welcomes contributions! Areas for improvement:

- Additional output formats
- Enhanced filtering capabilities  
- Performance optimizations
- Additional service name mappings
- Integration with other Tailscale APIs

## License

This project is open source. Please refer to the LICENSE file for details.

## Support

For issues, feature requests, or questions:
- Create an issue on GitHub
- Check the troubleshooting section above
- Review the help output: `./ts-logs --help`

---

**Status**: ✅ Beta Release - All core functionality tested and working. Accepting bug reports.
