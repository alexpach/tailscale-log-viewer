# TODO

## Performance Optimization
- [ ] Optimize multiple `jq` passes through data - combine operations where possible
- [ ] Implement caching for device lookups when fetching logs multiple times
- [ ] Add benchmarking for large log processing
- [x] Add timing information for API calls ✅ COMPLETED (2025-09-12)

## Code Organization
- [ ] Split 1153-line script into modules:
  - [ ] Core functions module
  - [ ] Formatting functions module
  - [ ] Filtering functions module
  - [ ] API interaction module
- [ ] Refactor long functions (format_table_output is 200+ lines)
- [ ] Create a configuration module for settings management

## Enhanced Features
- [x] Add CSV export format for spreadsheet analysis ✅ COMPLETED
- [ ] Implement filter presets (save/load common filter combinations)
- [ ] Add real-time monitoring mode (`--follow` option)
- [ ] Implement rate limiting awareness with backoff for API calls
- [ ] Support for multiple tailnets switching

## Testing
- [x] Create automated test suite: ✅ PARTIALLY COMPLETED (2025-09-12)
  - [x] Unit tests for date handling functions ✅ COMPLETED
  - [x] Unit tests for filtering logic ✅ COMPLETED
  - [x] Unit tests for formatting functions ✅ COMPLETED
  - [ ] Integration tests for API interactions
  - [ ] Mock API responses for offline testing
- [ ] Add GitHub Actions CI/CD pipeline
- [x] Create test data generator for development ✅ COMPLETED (2025-09-12)

## Security Enhancements
- [x] Add `--mask-ips` option to redact sensitive IP addresses in output ✅ COMPLETED (2025-09-12)
- [ ] Implement encrypted token storage (keychain integration)
- [ ] Add audit logging for compliance (who accessed what data when)
- [ ] Support for environment-specific token management
- [ ] Add token permission validation before operations

## Code Quality Improvements
- [x] Consolidate duplicate date handling code (GNU vs BSD date) ✅ COMPLETED (2025-09-12)
- [ ] Improve IPv6 regex patterns for better validation
- [x] Add validation for numeric arguments (prevent negative values) ✅ COMPLETED (2025-09-12)
- [x] Implement proper signal handling (SIGINT, SIGTERM) ✅ COMPLETED (2025-09-12)
- [x] Add `--debug` mode for troubleshooting ✅ COMPLETED (2025-09-12)
- [x] Improve error messages with error codes ✅ COMPLETED (added clear error messages for missing arguments)

## Documentation
- [ ] Add man page for the tool
- [ ] Create video tutorial/demo
- [ ] Add troubleshooting guide
- [ ] Document API rate limits and best practices
- [ ] Add contribution guidelines

## Platform Support
- [ ] Test and ensure Windows WSL compatibility
- [ ] Add PowerShell version for Windows native support
- [ ] Create Docker container for consistent environment
- [ ] Add Homebrew formula for easy macOS installation

## Monitoring & Observability
- [x] Add `--stats` flag to show processing statistics ✅ COMPLETED (2025-09-12)
- [ ] Implement progress bar for long operations
- [x] Add timing information for API calls ✅ COMPLETED (2025-09-12)
- [ ] Create health check endpoint integration

## Advanced Filtering
- [ ] Add regex support for source/destination filters
- [ ] Implement time-of-day filtering
- [ ] Add bandwidth threshold filtering
- [ ] Support for combining multiple traffic types
- [x] Add exclude filters (NOT operations) ✅ COMPLETED (2025-09-12)