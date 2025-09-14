# CHANGES.md

## 2025-01-14 - API Token Security Enhancement

### Changes Made

1. **Replaced get_api_token() with init_api_token()**
   - Old function used `echo` which could expose token in process listings
   - New function stores token in global variable `API_TOKEN_CACHED`
   - Eliminates subprocess creation and potential token exposure
   - Location: ts-logs lines 127-155

2. **Added Token Format Validation**
   - Validates that API tokens start with "tskey-"
   - Provides clear error message for invalid token formats
   - Helps catch configuration errors early

3. **Test Data Mode Enhancement**
   - Skip token initialization when using test data
   - Uses dummy token for test mode to avoid validation issues
   - Location: ts-logs lines 1811-1817

### Security Improvements

- **No echo exposure**: Token is never echoed, reducing process listing risks
- **No subprocess**: Direct variable assignment avoids subprocess creation
- **Shell trace safe**: Token less likely to appear in bash -x output
- **Validation**: Basic format checking ensures valid tokens

### Tests Created

1. **test/test_token_security.sh**
   - Verifies token not visible in process listings
   - Tests token format validation
   - Checks shell trace mode security
   - Validates new implementation

### Verification

Run the security test:
```bash
./test/test_token_security.sh
```

---

## 2025-01-13 - Critical Bug Fixes

### Changes Made

1. **Improved IP Address Filter Matching**
   - Modified filter_logs() function to detect IP addresses and use exact matching for IPs
   - Added is_ip_address() helper function to detect IPv4 and IPv6 addresses
   - IP addresses now use `==` comparison instead of `contains()` to prevent false positives
   - Machine names continue to use substring matching for flexibility
   - Location: ts-logs lines 1145-1260

2. **Enhanced Exclusion Filter Precision**
   - Updated should_exclude_flow() to use exact matching for IP addresses
   - IP addresses are now matched exactly while machine names use substring matching
   - Location: ts-logs lines 238-288

3. **Verified Security of Debug Mode**
   - Confirmed that debug mode does not expose API tokens in output
   - Token is passed via curl's -u flag, not shown in debug logs
   - Test: test/test_critical_bugs.sh

### Tests Created

1. **test/test_critical_bugs.sh**
   - Comprehensive test suite for all three critical bugs
   - Tests IPv6 address filtering with special characters
   - Verifies debug mode token redaction
   - Tests special character handling in filters

2. **test/test_filter_precision.sh**
   - Specific tests for filter matching precision
   - Demonstrates false positive issues with current implementation
   - Tests both inclusion and exclusion filters

3. **test/test_exact_match.sh**
   - Focused test for exact IP matching behavior
   - Simple test cases to verify exact match implementation

### Known Issues

1. **Filter Design Limitation**
   - Current filtering operates at the log entry level, not the traffic flow level
   - When a log entry contains multiple traffic flows and one matches the filter, ALL flows from that entry are included in the output
   - This causes apparent "false positives" even with exact matching
   - Solution requires refactoring to filter individual flows rather than entire log entries
   - Added to TODO.md as "Refactor filtering to work at flow level instead of log entry level"

### Verification

Run the test suite to verify the fixes:
```bash
./test/test_critical_bugs.sh
./test/test_filter_precision.sh
```

### Summary

- ✅ IPv6 addresses with special characters are properly escaped
- ✅ Debug mode does not expose sensitive tokens
- ✅ Filter matching uses exact match for IPs (at the filter level)
- ⚠️  Filter still shows all flows from matching log entries (architectural limitation)