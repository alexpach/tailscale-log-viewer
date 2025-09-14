# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Information

- **GitHub Username**: alexpach
- **Repository**: tailscale-logging
- **Last Major Update**: 2025-09-12 - Implemented 8 major enhancements: debug mode, stats, exclusion filters, IP masking, consolidated date handling, signal handling, test data generator, and comprehensive tests

## Repository Overview

This is an enhanced Tailscale network logging utility that fetches network logs from the Tailscale API with flexible time intervals, filtering, multiple output formats, and machine name resolution.

**Status**: ✅ Production Ready - All core functionality tested and working

## Testing Summary

The utility has been comprehensively tested with the following results:

### ✅ Core Features Verified
- **Help System**: Comprehensive help with clear examples
- **Configuration Management**: .env file support with helpful error messages
- **Output Formats**: Table (detailed flows), compact (simplified), CSV (spreadsheet export), JSON, and raw formats all working
- **Traffic Filtering**: Flow-level filtering for exit, subnet, physical, and virtual traffic
- **Time Range Options**: Minutes, hours, and other time range options working
- **Error Handling**: Helpful error messages that guide users to solutions

### ✅ Enhanced Features Working (Updated 2025-09-12)
- **Table Format (Default)**: Detailed flows with separate port columns (src-ip, src-port, dst-ip, dst-port, type, proto, txBytes, rxBytes)
- **Compact Format**: Simplified 4-column view (time, src-ip, dst-ip, type)
- **Enhanced Summary Format**: Comprehensive machine activity overview with aggregated statistics
- **Source/Destination Filtering**: Filter by machine name, IP address, or node ID with flow-level precision
- **IPv6 Support**: Full support for IPv6 addresses with proper column alignment
- **Service Name Resolution**: Common ports show as readable names (dhcpc, dhcps, prom, ntp, etc.)
- **Machine Name Resolution**: Tailscale IPs (100.x.x.x) resolve to readable machine names with fallback to IPs
- **Smart Error Messages**: Format/traffic type confusion now shows helpful guidance
- **Filtering Explanations**: Shows what criteria will be matched when using source/destination filters
- **Footer Headers**: Automatic header repetition for outputs longer than 20 lines
- **Streaming Output**: Real-time display as data is processed
- **5-Character Service Names**: All service names limited for clean column alignment
- **Local Timestamps**: Time shown in local timezone as HH:MM:SS format
- **Perfect Column Alignment**: All table formats have properly aligned headers and data
- **Missing Byte Values**: Proper handling of missing TX/RX bytes (shows 0 instead of blank)
- **Numeric Input Validation**: Time arguments (-m, -H, -d) validate for positive integers only (Added 2025-09-12)
- **CSV Export Format**: Export traffic data in CSV format for spreadsheet analysis (Added 2025-09-12)
- **Argument Validation**: All command-line options validate that required arguments are provided (Fixed 2025-09-12)
- **Debug Mode**: Verbose logging with `--debug` flag for troubleshooting API calls and processing (Added 2025-09-12)
- **Statistics Mode**: Processing statistics with `--stats` flag showing API times, record counts (Added 2025-09-12)
- **Exclusion Filters**: `--exclude-src` and `--exclude-dst` to filter out unwanted traffic (Added 2025-09-12)
- **IP Masking**: `--mask-ips` option for privacy, showing only first 2 octets of IPv4 addresses (Added 2025-09-12)
- **Consolidated Date Handling**: Unified date functions supporting both GNU and BSD date commands (Added 2025-09-12)
- **Signal Handling**: Proper cleanup on SIGINT/SIGTERM with statistics display (Added 2025-09-12)
- **Test Data Generator**: Script to generate mock JSON data for testing without API access (Added 2025-09-12)

### 🎯 Original Issue Resolved
The specific issue `./ts-logs -m 5 -t raw` now shows:
```
Error: 'raw' is an output format, not a traffic type.
Use: -f raw (for format) instead of -t raw
Valid traffic types for -t: virtual, subnet, exit, physical
```

## Project Structure

- `ts-logs`: Enhanced script that fetches Tailscale network logs with flexible options
- `.env`: Contains configuration (TAILNET, TAILSCALE_API_TOKEN) - copy from `.env.example`

## Common Commands

### Basic Usage
```bash
# Show help (default when no arguments provided)
./ts-logs

# Show help explicitly  
./ts-logs --help

# Most common usage patterns
./ts-logs -m 5          # Last 5 minutes in detailed table format
./ts-logs -m 5 -f compact  # Last 5 minutes in simplified view
./ts-logs -m 5 -s       # Last 5 minutes machine activity summary
./ts-logs -t exit -H 2  # Exit traffic details from last 2 hours
```

### Time Range Options
```bash
# Last N minutes/hours/days (short options preferred)
./ts-logs -m 30         # Last 30 minutes
./ts-logs -H 6          # Last 6 hours  
./ts-logs -d 3          # Last 3 days

# Specific time range
./ts-logs --since 2025-08-28T00:00:00Z --until 2025-08-28T23:59:59Z

# Convenient shortcuts
./ts-logs --today
./ts-logs --yesterday
```

### Output Formatting
```bash
# Table format - detailed flows with all columns (default)
./ts-logs -H 12

# Compact format - simplified 4-column view
./ts-logs -f compact -H 6

# Pretty JSON (requires jq or python3)
./ts-logs -f json -d 1

# Raw JSON output
./ts-logs -f raw

# Summary statistics only
./ts-logs -s -d 7
```

### Filtering Options
```bash
# Filter by traffic type
./ts-logs -t virtual -H 24
./ts-logs -t subnet --today
./ts-logs -t exit --today
./ts-logs -t physical -H 6

# Filter by source (machine name, IP, or partial match)
./ts-logs -S laptop-work -H 2
./ts-logs -S 100.64.0.1 -m 10
./ts-logs -S fd7a:115c:a1e0::1234 -m 5

# Filter by destination
./ts-logs -D 192.168.1 -H 1
./ts-logs -D server -m 30

# Combine filters
./ts-logs -S laptop-work -D 192.168.1 -t exit -H 1

# Combined filtering with summary analysis
./ts-logs -S laptop-work -t exit -s -H 6   # Laptop's exit traffic summary
./ts-logs -D server -t virtual -s --today # Virtual traffic to server summary

# Recent activity analysis  
./ts-logs -m 15 -s          # 15-minute machine activity summary
./ts-logs -m 5 -t exit      # Recent exit traffic details
./ts-logs -m 1 -t subnet -f compact  # Recent subnet activity
```

### Make Script Executable
```bash
chmod +x ts-logs
```

## Key Features

### Enhanced Summary Format (`--summary` or `-s`)
- **Machine-centric analysis**: Groups all activity by resolved machine names instead of nodeIDs
- **Comprehensive statistics**: Shows entries count, total TX/RX bytes, and traffic type participation
- **Perfect aggregation**: Multiple nodeIDs for the same machine are combined correctly
- **Traffic type indicators**: Visual checkmarks (✓) show which traffic types each machine participates in
- **Human-readable bytes**: Automatic formatting with appropriate units (GB, MB, KB, B)
- **Activity-based sorting**: Most active machines appear first
- **Respects all filters**: Works with source (-S), destination (-D), and traffic type (-t) filtering
- **Perfect table alignment**: All columns properly aligned with headers
- **Machine name resolution**: NodeIDs resolve to readable names with IP fallback when names unavailable

### Enhanced Table Format (Default)
- **Detailed flow information**: `Time`, `Src IP`, `SPort`, `Dst IP`, `DPort`, `Type`, `Proto`, `TxBytes`, `RxBytes`
- **IPv6 support**: Full support for IPv6 addresses with proper column alignment (43-character width)
- **Service name resolution**: Common ports show as service names (e.g., `80` → `http`, `443` → `https`, `9100` → `prom`)
- **Tailscale IP resolution**: `100.x.x.x` addresses resolve to machine names in all formats
- **Missing data handling**: Shows `0` for missing TX/RX bytes instead of blank columns
- **Traffic flow-level filtering**: Filter by traffic type shows only relevant flows, not entire log entries
- **Short service names**: All service names limited to 5 characters maximum for clean output
- **Local timestamp format**: Time shown as `HH:MM:SS` in local timezone
- **Perfect column alignment**: Headers and data properly aligned with consistent spacing
- **Footer headers**: Headers repeated at bottom for outputs longer than 20 lines

### Source/Destination Filtering
- **Machine name filtering**: `--src laptop-work` or `-S laptop-work`
- **IP address filtering**: `--src 100.64.0.1` or IPv6 `--src fd7a:115c:...`
- **Partial matching**: `--src laptop` matches any source containing "laptop"
- **Node ID filtering**: Filter by Tailscale node IDs
- **Combined filtering**: Use both `--src` and `--dst` together
- **Flow-level precision**: Filtering works on individual flows, not entire log entries
- **Filtering explanations**: Shows what criteria will be matched before output

### Machine Name Resolution
- **Universal IP resolution**: Table and compact formats resolve Tailscale IPs to machine names
- **Automatic tailnet suffix stripping**: Machine names like `server.tail43508.ts.net` are displayed as just `server`
- **Fallback to IP addresses**: If machine name lookup fails, displays the Tailscale IP address
- **API integration**: Uses Tailscale's `/devices` API endpoint to map IP addresses to machine names

### Traffic Type Analysis
- **Virtual traffic**: Direct Tailscale-to-Tailscale communication within the network
- **Subnet traffic**: Traffic to/from subnet routes (containers, internal services)
- **Exit traffic**: Traffic routed through exit nodes to external internet
- **Physical traffic**: Underlying physical network communication between nodes

### Command Line Interface
- **Default help behavior**: Running `ts-logs` without arguments shows help
- **Short option support**: Most options have single-letter shortcuts (`-m`, `-H`, `-d`, `-f`, `-t`, `-S`, `-D`)
- **Time options**: `--since` and `--until` use long-form only (no `-S`, `-U` shortcuts)
- **Default table format**: Detailed flow information by default
- **Flexible time ranges**: Minutes, hours, days, or specific time ranges
- **Streaming output**: Results appear in real-time as they're processed

## Example Output

### Enhanced Summary Format
```
=== Traffic Summary ===
Total log entries: 37
Unique nodes: 5
Traffic types found: exitTraffic, physicalTraffic, virtualTraffic

Machine Activity Summary:
Machine Name                    | Entries |   TX Bytes |   RX Bytes | Virtual |  Subnet |    Exit | Physical
------------------------------- | ------- | ---------- | ---------- | ------- | ------- | ------- | --------
laptop-work                     |      37 |   525.6 KB |     8.1 KB |    ✓    |         |         |    ✓   
desktop-home                    |      12 |    29.1 KB |    17.0 KB |    ✓    |         |    ✓    |    ✓   
server-prod                     |       8 |     1.0 KB |        0 B |         |         |    ✓    |         
dev-machine                     |       6 |      600 B |        0 B |         |         |    ✓    |         
100.64.0.5                      |       2 |      420 B |      156 B |         |         |    ✓    |    ✓   

Traffic Types:
  Virtual  - Direct Tailscale-to-Tailscale communication
  Subnet   - Traffic to/from subnet routes
  Exit     - Traffic through exit nodes to external internet
  Physical - Underlying physical network communication
```

### Table Format (Default) - Exit Traffic
```
# Filtering criteria:
# - Showing flows with traffic type 'exit'
#
Time     Src IP                                      SPort    Dst IP                                      DPort    Type     Proto TxBytes  RxBytes
--------|-------------------------------------------|--------|-------------------------------------------|--------|--------|-----|--------|-------
14:32:16 laptop-work                                 dhcpc    192.168.1.1                                 dhcps    exit     UDP   328      
14:32:20 server-prod                                 35832    203.0.113.10                                http     exit     TCP   60       
14:32:24 dev-machine                                 59738    198.51.100.5                                http     exit     TCP   180      
14:32:28 desktop-home                                49672    192.168.1.1                                 dns      exit     TCP   120      
```

### Compact Format - Subnet Traffic
```
# Filtering criteria:
# - Showing flows with traffic type 'subnet'
#
Time     Src IP                                      Dst IP                                      Type
--------|-------------------------------------------|-------------------------------------------|--------
14:31:36 172.17.0.1                                 10.0.1.10                                   subnet
14:31:43 172.17.0.1                                 10.0.1.10                                   subnet
14:31:46 172.17.0.1                                 10.0.1.20                                   subnet
```

### Source Filtering Example
```
# Filtering criteria:
# - Showing flows with source matching 'laptop-work', '100.64.0.1', or partial matches
#
Time     Src IP                                      SPort    Dst IP                                      DPort    Type     Proto TxBytes  RxBytes
--------|-------------------------------------------|--------|-------------------------------------------|--------|--------|-----|--------|-------
16:48:54 laptop-work                                 52036    203.0.113.50                                https    exit     TCP   104      52
16:49:02 laptop-work                                 nbns     laptop-work                                 nbns     virtual  UDP            1044
16:49:10 laptop-work                                 51229    198.51.100.88                               5228     exit     TCP   52      
```

### Service Name Examples
Common ports are automatically resolved to short, recognizable service names:
- Port `80` → `http`, `443` → `https`
- Port `53` → `dns`, `22` → `ssh`  
- Port `68` → `dhcpc` (DHCP client), `67` → `dhcps` (DHCP server)
- Port `9100` → `prom` (Prometheus metrics)
- Port `3306` → `mysql`, `5432` → `pgsql`

## Test Data Support

The utility includes comprehensive test data support for offline testing and development:

### Test Data Generation
- **Command**: `./ts-logs --generate-test-data`
- **Purpose**: Creates realistic test data without requiring API access
- **Output**: Saves to `examples/test-data-YYYYMMDD.json`
- **Contents**: 50 log entries with various traffic types and device information

### Using Test Data
- **Command**: `./ts-logs --use-test-data [options]`
- **Purpose**: Uses cached test data instead of making API calls
- **Benefits**:
  - Enables offline testing and development
  - Avoids API rate limits during testing
  - Provides consistent test results
  - Prevents timeouts with large data requests
  - All formatting and filtering features work with test data

### Test Scripts
All test scripts automatically generate test data if not present and use it to avoid API dependencies:
- `test/test_numeric_validation.sh` - Validates time range parameters
- `test/test_csv_output.sh` - Tests CSV export functionality
- `test/test_new_features.sh` - Tests debug mode, stats, filters, etc.

## Testing Verification

The utility has been verified to work correctly with actual Tailscale network data:

### Real Output Examples (from testing):
```bash
# Exit traffic shows DHCP and NTP activity
./ts-logs -m 2 -t exit
Time     Src IP                                      SPort    Dst IP                                      DPort    Type     Proto TxBytes  RxBytes
--------|-------------------------------------------|--------|-------------------------------------------|--------|--------|-----|--------|-------
09:51:31 laptop-work                                 dhcpc    192.168.1.1                                 dhcps    exit     UDP   328      
09:51:31 laptop-work                                 45320    192.168.1.1                                 ntp      exit     UDP   76       

# Physical traffic shows node-to-node communication  
./ts-logs -m 1 -t physical
Time     Src IP                                      SPort    Dst IP                                      DPort    Type     Proto TxBytes  RxBytes
--------|-------------------------------------------|--------|-------------------------------------------|--------|--------|-----|--------|-------
09:52:26 dev-node1                                   0        203.0.113.134                               41641    physical       672      32
09:52:25 prod-node2                                  0        198.51.100.171                              6949     physical       32       576

# Source filtering with IPv6 support
./ts-logs -m 5 -S fd7a:115c:a1e0::1234
# Filtering criteria:
# - Showing flows with source matching 'fd7a:115c:a1e0::1234', IP addresses, or partial matches
#
Time     Src IP                                      SPort    Dst IP                                      DPort    Type     Proto TxBytes  RxBytes
--------|-------------------------------------------|--------|-------------------------------------------|--------|--------|-----|--------|-------
13:41:43 [fd7a:115c:a1e0::1234]                      52044    [2001:db8::5678]                            https    exit     TCP   84      
```

All examples show:
- ✅ Machine name resolution (laptop-work, dev-node1 instead of 100.x.x.x IPs)  
- ✅ Service name resolution (dhcpc, dhcps, ntp, https instead of port numbers)
- ✅ IPv6 address support with proper column alignment (43-character width)
- ✅ Pipe-separated headers for clear column distinction
- ✅ Traffic filtering working at flow level, not log entry level
- ✅ Filtering explanations showing what criteria will be matched
- ✅ Footer headers for long outputs (>20 lines)
- ✅ Streaming output for real-time results

## Dependencies

- **curl**: For API requests (required)
- **jq**: For JSON processing and table formatting (recommended)
- **python3**: Fallback for JSON formatting if jq unavailable
- **gdate**: GNU date for better date parsing on macOS (optional, falls back to system date)

Install jq on macOS: `brew install jq`
Install jq on Ubuntu/Debian: `apt-get install jq`

## Configuration

Create a `.env` file from the provided `.env.example`:

```bash
cp .env.example .env
# Edit .env with your actual values
```

Example `.env` file:
```bash
TAILSCALE_API_TOKEN=tskey-api-your-actual-token-here
TAILNET=your-company.com
```

## Security Notes

- **API Token Permissions**: The script requires access tokens with `logs:network:read` and `devices:read` scopes
- **Configuration file**: Use `.env` file for configuration (never commit this file)
- **Environment variables**: Can also set `TAILSCALE_API_TOKEN` and `TAILNET` as environment variables
- **Token format**: `tskey-api-*` format for API access

## API Endpoints Used

The script integrates with multiple Tailscale API endpoints:

### Network Logs API
- **URL**: `https://api.tailscale.com/api/v2/tailnet/{tailnet}/logging/network`
- **Purpose**: Fetch network flow logs
- **Parameters**: `start` and `end` timestamps in RFC 3339 format
- **Limitation**: Logs available for the most recent 30 days only

### Devices API  
- **URL**: `https://api.tailscale.com/api/v2/tailnet/{tailnet}/devices`
- **Purpose**: Fetch device information for machine name resolution
- **Usage**: Called automatically when using table format
- **Data**: Provides machine names, IP addresses, and device metadata

## Error Handling

The script includes comprehensive error handling:
- Date format validation with RFC 3339 compliance
- API response error checking for both endpoints
- Missing dependency warnings with installation instructions
- Invalid argument detection with helpful error messages
- Network connectivity issue detection
- Graceful fallback when machine name lookup fails