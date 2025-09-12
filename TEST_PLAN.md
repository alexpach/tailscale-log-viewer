# Test Plan for ts-logs Utility

## Overview
This test plan covers verification of all features in the enhanced Tailscale network logging utility, including the new summary format, improved filtering, and table alignment fixes.

## Test Environment
- **Script**: `./ts-logs`
- **Dependencies**: jq (required), bc (optional for decimal formatting)
- **Configuration**: `.env` file with `TAILSCALE_API_TOKEN` and `TAILNET`

## Core Functionality Tests

### 1. Help and Configuration Tests
- [ ] **T001**: `./ts-logs` (no arguments) shows help
- [ ] **T002**: `./ts-logs --help` shows comprehensive help
- [ ] **T003**: `./ts-logs -h` shows help (short option)
- [ ] **T004**: Missing `.env` file shows helpful error message
- [ ] **T005**: Invalid API token shows clear error
- [ ] **T006**: Invalid tailnet name shows clear error

### 2. Time Range Options Tests
- [ ] **T007**: `./ts-logs -m 5` (last 5 minutes)
- [ ] **T008**: `./ts-logs -H 2` (last 2 hours)
- [ ] **T009**: `./ts-logs -d 1` (last 1 day)
- [ ] **T010**: `./ts-logs --today` (today's traffic)
- [ ] **T011**: `./ts-logs --yesterday` (yesterday's traffic)
- [ ] **T012**: `./ts-logs --since 2025-01-01T00:00:00Z --until 2025-01-01T23:59:59Z` (specific range)
- [ ] **T013**: Invalid date format shows helpful error

#### 2.1 Numeric Validation Tests (Added 2025-09-12)
- [x] **T013a**: `./ts-logs -m -5` shows validation error (negative values rejected)
- [x] **T013b**: `./ts-logs -H 0` shows validation error (zero values rejected)
- [x] **T013c**: `./ts-logs -d 3.5` shows validation error (decimal values rejected)
- [x] **T013d**: `./ts-logs -m abc` shows validation error (non-numeric rejected)
- [x] **T013e**: `./ts-logs -H 05` shows validation error (leading zeros rejected)
- [x] **T013f**: `./ts-logs -m 30` accepts valid positive integers
- [x] **T013g**: `./ts-logs -H 168` accepts large valid numbers
- [x] **T013h**: Error messages clearly state "must be a positive integer (1 or greater)"

### 3. Output Format Tests

#### 3.1 Table Format (Default)
- [ ] **T014**: Default output shows table format with all columns
- [ ] **T015**: Table headers align properly with data
- [ ] **T016**: Missing TX/RX bytes show as "0" instead of blank
- [ ] **T017**: IPv6 addresses display correctly without breaking alignment
- [ ] **T018**: Machine name resolution works (100.x.x.x → readable names)
- [ ] **T019**: Service name resolution works (80 → http, 443 → https, etc.)
- [ ] **T020**: Footer headers appear for outputs longer than 20 lines
- [ ] **T021**: Streaming output appears in real-time

#### 3.2 Compact Format
- [ ] **T022**: `./ts-logs -f compact` shows 4-column format
- [ ] **T023**: Compact format has proper column alignment
- [ ] **T024**: Compact headers align with data

#### 3.3 Enhanced Summary Format
- [ ] **T025**: `./ts-logs -s` shows machine activity summary
- [ ] **T026**: `./ts-logs --summary` shows machine activity summary
- [ ] **T027**: Summary groups by machine name (no duplicates)
- [ ] **T028**: Summary shows correct entry counts per machine
- [ ] **T029**: Summary shows correct TX/RX byte totals
- [ ] **T030**: Summary formats bytes with appropriate units (B, KB, MB, GB)
- [ ] **T031**: Traffic type indicators (✓) display correctly
- [ ] **T032**: Summary table alignment is perfect
- [ ] **T033**: Summary sorts by activity (most active first)
- [ ] **T034**: Machine name resolution works in summary
- [ ] **T035**: IP fallback works when machine names unavailable
- [ ] **T036**: NodeID fallback works when no IPs found

#### 3.4 JSON Formats
- [ ] **T037**: `./ts-logs -f json` shows pretty-printed JSON
- [ ] **T038**: `./ts-logs -f raw` shows raw JSON
- [ ] **T039**: JSON output is valid and parseable

### 4. Traffic Type Filtering Tests
- [ ] **T040**: `./ts-logs -t virtual` shows only virtual traffic
- [ ] **T041**: `./ts-logs -t subnet` shows only subnet traffic
- [ ] **T042**: `./ts-logs -t exit` shows only exit traffic
- [ ] **T043**: `./ts-logs -t physical` shows only physical traffic
- [ ] **T044**: Invalid traffic type shows helpful error
- [ ] **T045**: Traffic type filtering explanation appears above output

### 5. Source/Destination Filtering Tests

#### 5.1 Source Filtering
- [ ] **T046**: `./ts-logs -S machine-name` filters by machine name
- [ ] **T047**: `./ts-logs -S 100.64.0.5` filters by Tailscale IP
- [ ] **T048**: `./ts-logs -S 192.168.1.1` filters by regular IP
- [ ] **T049**: `./ts-logs -S fd7a:115c::1` filters by IPv6 address
- [ ] **T050**: `./ts-logs -S nodeId123` filters by node ID
- [ ] **T051**: Source filtering only shows matching traffic (no false positives)
- [ ] **T052**: Source filtering explanation appears above output

#### 5.2 Destination Filtering  
- [ ] **T053**: `./ts-logs -D machine-name` filters by machine name
- [ ] **T054**: `./ts-logs -D 100.64.0.5` filters by Tailscale IP
- [ ] **T055**: `./ts-logs -D 192.168.1.1` filters by regular IP
- [ ] **T056**: `./ts-logs -D fd7a:115c::1` filters by IPv6 address
- [ ] **T057**: `./ts-logs -D 127.3.3.40` filters by coordinator IP
- [ ] **T058**: Destination filtering only shows matching traffic (no false positives)
- [ ] **T059**: Destination filtering explanation appears above output

### 6. Combined Filtering Tests
- [ ] **T060**: `./ts-logs -S machine1 -D machine2` (source AND destination)
- [ ] **T061**: `./ts-logs -S machine1 -t virtual` (source AND traffic type)
- [ ] **T062**: `./ts-logs -D server -t exit` (destination AND traffic type)  
- [ ] **T063**: `./ts-logs -S laptop -D server -t virtual` (all three filters)
- [ ] **T064**: Combined filters work correctly with all output formats

### 7. Summary Filtering Integration Tests
- [ ] **T065**: `./ts-logs -s -S machine-name` shows filtered summary
- [ ] **T066**: `./ts-logs -s -D server` shows filtered summary
- [ ] **T067**: `./ts-logs -s -t virtual` shows filtered summary
- [ ] **T068**: `./ts-logs -s -S laptop -t exit` shows combined filtered summary
- [ ] **T069**: Filtered summary only includes matching traffic
- [ ] **T070**: Filtered summary shows correct aggregated statistics
- [ ] **T071**: Empty filtered results show appropriate message

### 8. Machine Name Resolution Tests
- [ ] **T072**: Tailscale IPs (100.x.x.x) resolve to machine names
- [ ] **T073**: Machine names strip tailnet suffixes (.tailXXX.ts.net)
- [ ] **T074**: Long machine names truncate appropriately
- [ ] **T075**: Offline/unknown machines show IP address as fallback
- [ ] **T076**: Missing machine data falls back to shortened nodeID
- [ ] **T077**: IPv6 Tailscale addresses resolve correctly

### 9. Service Name Resolution Tests
- [ ] **T078**: Common ports resolve to service names (http, https, ssh, dns)
- [ ] **T079**: DHCP ports resolve correctly (dhcpc, dhcps)
- [ ] **T080**: Prometheus port 9100 resolves to "prom"
- [ ] **T081**: All service names are 5 characters or fewer
- [ ] **T082**: Unknown ports display as numbers
- [ ] **T083**: Port 0 displays correctly

### 10. IPv6 Support Tests
- [ ] **T084**: IPv6 addresses display without breaking table layout
- [ ] **T085**: IPv6 filtering works correctly
- [ ] **T086**: IPv6 addresses with ports parse correctly ([ipv6]:port)
- [ ] **T087**: IPv6 addresses in compact format work
- [ ] **T088**: IPv6 addresses in summary format work

### 11. Error Handling Tests
- [ ] **T089**: `./ts-logs -t raw` shows helpful error (format vs traffic type)
- [ ] **T090**: `./ts-logs -f invalid` shows format error
- [ ] **T091**: Network connectivity issues show clear errors
- [ ] **T092**: API rate limiting handled gracefully
- [ ] **T093**: Malformed JSON responses handled properly
- [ ] **T094**: Missing jq dependency shows helpful error

### 12. Performance and Reliability Tests
- [ ] **T095**: Large datasets (1000+ entries) process correctly
- [ ] **T096**: Long time ranges (7+ days) work without timeouts
- [ ] **T097**: Summary aggregation works with many machines (20+)
- [ ] **T098**: Memory usage remains reasonable with large datasets
- [ ] **T099**: Streaming output works smoothly without buffering
- [ ] **T100**: Keyboard interrupt (Ctrl+C) exits cleanly

## Test Data Scenarios

### Scenario 1: Mixed Traffic Types
- Virtual traffic between machines
- Exit traffic through exit nodes
- Physical traffic (coordination)
- Subnet traffic to containers

### Scenario 2: Multiple Machine Names
- Machines with readable names
- Machines with only IP addresses
- Machines with only nodeIDs
- Mix of IPv4 and IPv6

### Scenario 3: High Activity Periods
- Busy machines with many connections
- Large data transfers
- Multiple simultaneous flows

### Scenario 4: Edge Cases
- Empty result sets
- Single machine traffic
- Very short time windows
- Very long machine names

## Regression Tests

### Priority 1: Critical Function
- [ ] **R001**: Summary format works without duplicates
- [ ] **R002**: Source/destination filtering is accurate
- [ ] **R003**: Table alignment is perfect
- [ ] **R004**: Machine name resolution works

### Priority 2: Important Features
- [ ] **R005**: All output formats work correctly
- [ ] **R006**: Combined filtering works
- [ ] **R007**: IPv6 support works
- [ ] **R008**: Error messages are helpful

### Priority 3: Nice to Have
- [ ] **R009**: Service name resolution works
- [ ] **R010**: Footer headers appear correctly
- [ ] **R011**: Streaming output works smoothly

## Test Execution Notes

### Required Test Commands
```bash
# Basic functionality
./ts-logs
./ts-logs -m 5
./ts-logs -m 5 -f compact
./ts-logs -m 5 -s

# Filtering tests
./ts-logs -m 5 -t exit
./ts-logs -m 5 -S machine-name
./ts-logs -m 5 -D 127.3.3.40
./ts-logs -m 5 -s -S machine-name

# Format tests
./ts-logs -m 5 -f json
./ts-logs -m 5 -f raw

# Error condition tests
./ts-logs -t raw
./ts-logs -f invalid
```

### Success Criteria
1. All output formats display with proper alignment
2. Filtering works accurately with no false positives
3. Summary format aggregates correctly by machine name
4. Machine names resolve properly with appropriate fallbacks
5. Error messages are helpful and guide users to solutions

### Known Issues / Limitations
- Network logs are only available for the most recent 30 days
- API rate limiting may affect large queries
- Some machines may not resolve names if offline during query

## Test Results Template

```
Test Run: [Date]
Tester: [Name]
Environment: [OS/Shell]
ts-logs Version: [Commit/Version]

Passed: ___/100
Failed: ___/100
Skipped: ___/100

Critical Issues: [List]
Minor Issues: [List]
Notes: [Additional observations]
```