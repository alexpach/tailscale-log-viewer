# TODO

## Critical Bugs & Correctness
- [ ] Refactor filtering to work at flow level instead of log entry level (current design shows all flows from matching entries)

## Performance Optimization
- [ ] Optimize multiple `jq` passes through data - combine operations where possible
- [ ] Add device caching with TTL (~5-10 minutes) in ~/.cache/ts-logs/devices.json
- [ ] Implement name resolution via jq instead of per-line Bash processing
- [ ] Add benchmarking for large log processing

## New Features
- [ ] Add `--version` flag to show script version
- [ ] Add `--no-resolve-names` flag to skip device fetch for speed
- [ ] Add `--no-service-names` flag to disable port→service translation
- [ ] Add `--follow` flag for polling tail mode (real-time monitoring)
- [ ] Add `--output FILE` flag to direct output to file
- [ ] Add regex support for source/destination filters with `--regex` flag
- [ ] Implement filter presets (save/load common filter combinations)
- [ ] Support for multiple tailnets switching
- [ ] Implement time-of-day filtering
- [ ] Add bandwidth threshold filtering

## Code Organization
- [ ] Split 1600+ line script into modules:
  - [ ] lib/api.sh (curl, error handling, caching)
  - [ ] lib/format.sh (table/compact/summary helpers and byte/unit formatting)
  - [ ] lib/filter.sh (jq filters and safe arg passing)
  - [ ] lib/util.sh (date parsing, logging, signal traps)
  - [ ] bin/ts-logs (CLI arg parsing and orchestration)
- [ ] Refactor long functions (format_table_output is 200+ lines)
- [ ] Create a configuration module for settings management

## Testing & CI
- [ ] Create offline test fixtures with sample JSON files
- [ ] Create Makefile with test targets (make test, make lint, make format)
- [ ] Add GitHub Actions CI workflow:
  - [ ] shellcheck and shfmt format check
  - [ ] Offline tests (no real API calls)
  - [ ] Online integration tests (opt-in with env vars)
- [ ] Add mock API responses for offline testing
- [ ] Integration tests for API interactions

## Documentation
- [ ] Update README - remove Beta status, document Bash 3.2 vs 4+ requirements
- [ ] Add API rate limits documentation and expected behavior
- [ ] Add man page for the tool
- [ ] Create video tutorial/demo
- [ ] Add troubleshooting guide
- [ ] Add contribution guidelines
- [ ] Include sample JSON payload for offline usage examples

## Platform Support
- [ ] Check Bash version compatibility (3.2 vs 4+ features)
- [ ] Test and ensure Windows WSL compatibility
- [ ] Add PowerShell version for Windows native support
- [ ] Create Docker container for consistent environment
- [ ] Add Homebrew formula for easy macOS installation

## Security Enhancements
- [ ] Implement encrypted token storage (keychain integration)
- [ ] Add audit logging for compliance (who accessed what data when)
- [ ] Support for environment-specific token management
- [ ] Add token permission validation before operations
- [ ] Consider supporting system keychains (macOS keychain, pass/gnome-keyring)

## Monitoring & Observability
- [ ] Implement progress bar for long operations
- [ ] Create health check endpoint integration

---

## Completed Items

### 2025-01-14
- [x] Improve API token security - use global variable instead of echo - [437a33a](https://github.com/alexpach/tailscale-logging/commit/437a33a)
- [x] Remove api-token file support (legacy cleanup) - [Uncommitted]

### 2025-01-13 (Session 2)
- [x] Fix jq escaping for special characters in filters (IPv6 addresses work correctly) - [ca5733a](https://github.com/alexpach/tailscale-logging/commit/ca5733a)
- [x] Improve filter matching to use exact match for IP addresses - [ca5733a](https://github.com/alexpach/tailscale-logging/commit/ca5733a)
- [x] Ensure debug mode redacts tokens/sensitive data (verified safe) - [ca5733a](https://github.com/alexpach/tailscale-logging/commit/ca5733a)
- [x] Add is_ip_address() helper function for IP detection - [ca5733a](https://github.com/alexpach/tailscale-logging/commit/ca5733a)
- [x] Create comprehensive test suite for critical bugs - [ca5733a](https://github.com/alexpach/tailscale-logging/commit/ca5733a)
- [x] Document filter design limitation in CHANGES.md - [ca5733a](https://github.com/alexpach/tailscale-logging/commit/ca5733a)
- [x] Create RESEARCH.md documentation - [Uncommitted]

### 2025-01-13 (Session 1)
- [x] Add `--generate-test-data` parameter to generate realistic fake test data - [Uncommitted]
- [x] Add `--use-test-data` parameter to use cached test data instead of API calls - [Uncommitted]
- [x] Update test scripts to use test data for large time ranges to avoid API timeouts - [Uncommitted]
- [x] Fix test data generator JSON syntax errors (extra closing braces) - [Uncommitted]
- [x] Implement test data loading for both logs and devices endpoints - [Uncommitted]
- [x] Add automatic test data generation in test scripts if not present - [Uncommitted]

### 2025-01-13
- [x] Remove unused `format_date_rfc3339` function - [Uncommitted]
- [x] Add robust curl error handling (`-fsS --retry 3 --retry-connrefused`) - [Uncommitted]
- [x] Improve HTTP error messages (401/403/429/404) with actionable guidance - [Uncommitted]
- [x] Fix device mapping to use all addresses (IPv4 and IPv6) - [Uncommitted]
- [x] Add IPv6 support to summary machine-name resolution - [Uncommitted]
- [x] Add timeout/gtimeout fallback for macOS compatibility in tests - [Uncommitted]
- [x] Fix -v/--verbose documentation (replaced with --debug) - [8dfa022](https://github.com/alexpach/tailscale-logging/commit/8dfa022)
- [x] Fix timestamp calculation for macOS compatibility - [832b44f](https://github.com/alexpach/tailscale-logging/commit/832b44f)
- [x] Address shellcheck warnings and improve script quality - [8c98d35](https://github.com/alexpach/tailscale-logging/commit/8c98d35)

### 2025-01-12
- [x] Implement 8 major enhancements (debug mode, stats, exclusion filters, IP masking, etc.) - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Add CSV export format for spreadsheet analysis - [296c795](https://github.com/alexpach/tailscale-logging/commit/296c795)
- [x] Add numeric validation for time arguments (prevent negative values) - [cabba81](https://github.com/alexpach/tailscale-logging/commit/cabba81)
- [x] Organize test files into test directory - [a0a4859](https://github.com/alexpach/tailscale-logging/commit/a0a4859)
- [x] Add `--debug` mode for troubleshooting - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Add `--stats` flag to show processing statistics - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Add `--mask-ips` option to redact sensitive IP addresses - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Add exclude filters (`--exclude-src`, `--exclude-dst`) - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Implement proper signal handling (SIGINT, SIGTERM) - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Consolidate duplicate date handling code (GNU vs BSD date) - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Add timing information for API calls - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Create test data generator for development - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Create automated test suite (unit tests for date handling, filtering, formatting) - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)
- [x] Improve error messages with clear guidance - [9fdd856](https://github.com/alexpach/tailscale-logging/commit/9fdd856)

### Earlier
- [x] Initial implementation with comprehensive features - [4ba8270](https://github.com/alexpach/tailscale-logging/commit/4ba8270)