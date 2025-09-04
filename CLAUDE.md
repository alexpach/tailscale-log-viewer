# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Information

- **GitHub Username**: alexpach
- **Repository**: tailscale-logging

## Repository Overview

This is an enhanced Tailscale network logging utility that fetches network logs from the Tailscale API with flexible time intervals, filtering, multiple output formats, and machine name resolution.

**Status**: ✅ Production Ready - All core functionality tested and working

## Testing Summary

The utility has been comprehensively tested with the following results:

### ✅ Core Features Verified
- **Help System**: Comprehensive help with clear examples
- **Configuration Management**: .env file support with helpful error messages
- **Output Formats**: Table, JSON, raw, and enhanced full format all working
- **Traffic Filtering**: Flow-level filtering for exit, subnet, physical, and virtual traffic
- **Time Range Options**: Minutes, hours, and other time range options working
- **Error Handling**: Helpful error messages that guide users to solutions

### ✅ Enhanced Features Working
- **Full Format**: Separate port columns (src-ip, src-port, dst-ip, dst-port)
- **Service Name Resolution**: Common ports show as readable names (dhcpc, dhcps, prom, ntp, etc.)
- **Machine Name Resolution**: Tailscale IPs (100.x.x.x) resolve to readable machine names
- **Smart Error Messages**: Format/traffic type confusion now shows helpful guidance
- **5-Character Service Names**: All service names limited for clean column alignment
- **Local Timestamps**: Time shown in local timezone as HH:MM:SS format

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
- `api-token`: Legacy API token file (deprecated, use .env instead)

## Common Commands

### Basic Usage
```bash
# Show help (default when no arguments provided)
./ts-logs

# Show help explicitly  
./ts-logs --help

# Most common usage patterns
./ts-logs -m 5          # Last 5 minutes in table format
./ts-logs -m 5 -f full  # Last 5 minutes with detailed flows
./ts-logs -t exit -f full -H 2  # Exit traffic details from last 2 hours
```

### Time Range Options
```bash
# Last N minutes/hours/days (short options preferred)
./ts-logs -m 30         # Last 30 minutes
./ts-logs -H 6          # Last 6 hours  
./ts-logs -d 3          # Last 3 days

# Specific time range
./ts-logs -S 2025-08-28T00:00:00Z -U 2025-08-28T23:59:59Z

# Convenient shortcuts
./ts-logs --today
./ts-logs --yesterday
```

### Output Formatting
```bash
# Table format with machine names (default)
./ts-logs --format table --hours 12

# Compact format - one line per entry
./ts-logs --format compact --hours 6

# Full format - detailed traffic flows with separate port columns
./ts-logs --format full --hours 2

# Pretty JSON (requires jq or python3)
./ts-logs --format json --days 1

# Raw JSON output
./ts-logs --format raw

# Summary statistics only
./ts-logs --summary --days 7
```

### Filtering and Machine Names
```bash
# Filter by traffic type with short options
./ts-logs -t virtual -f table -H 24
./ts-logs -t subnet -f full --today
./ts-logs -t exit -f full --today
./ts-logs -t physical -f table -H 6

# Filter by node ID
./ts-logs -n "node123" -d 2

# View exit traffic with detailed breakdown (most useful for troubleshooting)
./ts-logs -t exit -f full -H 6

# Recent activity analysis
./ts-logs -m 15 -f table
./ts-logs -m 5 -t exit -f full
./ts-logs -m 1 -t subnet -f full
```

### Make Script Executable
```bash
chmod +x ts-logs
```

## Key Features

### Enhanced Full Format (New!)
- **Separate port columns**: `Src IP`, `SPort`, `Dst IP`, `DPort` for better readability
- **Service name resolution**: Common ports show as service names (e.g., `80` → `http`, `443` → `https`, `9100` → `prom`)
- **Tailscale IP resolution**: `100.x.x.x` addresses resolve to machine names in all formats
- **Traffic flow-level filtering**: Filter by traffic type shows only relevant flows, not entire log entries
- **Short service names**: All service names limited to 5 characters maximum for clean output
- **Local timestamp format**: Time shown as `HH:MM:SS` in local timezone

### Machine Name Resolution
- **Universal IP resolution**: Table, compact, and full formats resolve Tailscale IPs to machine names
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
- **Short option support**: All options have single-letter shortcuts (`-m`, `-H`, `-d`, `-f`, `-t`, etc.)
- **Default table format**: Clean, readable output by default
- **Flexible time ranges**: Minutes, hours, days, or specific time ranges

## Example Output

### Exit Traffic Full Format (Most Detailed)
```
Time     Src IP               SPort    Dst IP               DPort    Type     Proto TxBytes  RxBytes
----------------------------------------------------------------------------------------------------
14:32:16 skep6                dhcpc    192.168.178.1        dhcps    exit     UDP   328      
14:32:20 rgbeast              35832    185.125.190.98       http     exit     TCP   60       
14:32:24 orin-dev             59738    91.189.91.96         http     exit     TCP   180      
14:32:28 laptop-work          49672    192.168.178.1        dns      exit     TCP   120      
```

### Subnet Traffic Analysis
```
Time     Src IP               SPort    Dst IP               DPort    Type     Proto TxBytes  RxBytes
----------------------------------------------------------------------------------------------------
14:31:36 172.17.0.1           prom     10.123.123.13        37252    subnet   TCP   300      
14:31:43 172.17.0.1           8005     10.123.123.13        32838    subnet   TCP   60       
14:31:46 172.17.0.1           5557     10.123.123.29        33630    subnet   TCP   180      
```

### Table Format (Default)
```
Timestamp                Machine Name             Traffic Type    Duration
------------------------------------------------------------------------
2025-08-29T14:32:04Z     server1                  exit            2025-08-29T14:32:02Z
2025-08-29T14:32:14Z     rgbeast                  subnet          2025-08-29T14:32:12Z
2025-08-29T14:32:19Z     laptop-work              physical        2025-08-29T14:32:17Z
```

### Service Name Examples
Common ports are automatically resolved to short, recognizable service names:
- Port `80` → `http`, `443` → `https`
- Port `53` → `dns`, `22` → `ssh`  
- Port `68` → `dhcpc` (DHCP client), `67` → `dhcps` (DHCP server)
- Port `9100` → `prom` (Prometheus metrics)
- Port `3306` → `mysql`, `5432` → `pgsql`

## Testing Verification

The utility has been verified to work correctly with actual Tailscale network data:

### Real Output Examples (from testing):
```bash
# Exit traffic shows DHCP and NTP activity
./ts-logs -m 2 -t exit -f full
Time     Src IP               SPort    Dst IP               DPort    Type     Proto TxBytes  RxBytes
----------------------------------------------------------------------------------------------------
09:51:31 skep6                dhcpc    192.168.178.1        dhcps    exit     UDP   328      
09:51:31 skep6                45320    192.168.178.1        ntp      exit     UDP   76       

# Physical traffic shows node-to-node communication  
./ts-logs -m 1 -t physical -f full
Time     Src IP               SPort    Dst IP               DPort    Type     Proto TxBytes  RxBytes
----------------------------------------------------------------------------------------------------
09:52:26 queen2dev            0        34.77.239.134        41641    physical       672      32
09:52:25 skep6                0        109.202.219.171      6949     physical       32       576

# Subnet traffic shows container/internal services
./ts-logs -m 1 -t subnet -f full  
Time     Src IP               SPort    Dst IP               DPort    Type     Proto TxBytes  RxBytes
----------------------------------------------------------------------------------------------------
09:52:21 172.17.0.1           prom     10.123.123.13        51952    subnet   TCP   300      
09:52:21 172.17.0.1           8005     10.123.123.13        47520    subnet   TCP   120      
```

All examples show:
- ✅ Machine name resolution (skep6, queen2dev instead of 100.x.x.x IPs)  
- ✅ Service name resolution (dhcpc, dhcps, ntp, prom instead of port numbers)
- ✅ Perfect column alignment with proper spacing
- ✅ Traffic filtering working at flow level, not log entry level

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
- **Legacy support**: Still supports `api-token` file for backward compatibility

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