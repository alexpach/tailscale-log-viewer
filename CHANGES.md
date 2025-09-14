# CHANGES.md

## 2025-01-14 - OAuth Client Authentication Support

### New Feature: OAuth Client Authentication

1. **Implemented OAuth 2.0 client credentials flow**
   - Added support for `TAILSCALE_CLIENT_ID` and `TAILSCALE_CLIENT_SECRET`
   - OAuth tokens automatically refresh before expiry (1-hour lifetime)
   - Seamless fallback between OAuth and API token authentication
   - Location: ts-logs lines 130-260

2. **Authentication Methods**
   - API Token: Simple, full permissions, set via `TAILSCALE_API_TOKEN`
   - OAuth Client: Granular permissions, auto-refresh, set via client credentials
   - Script automatically detects which method to use

3. **Implementation Details**
   - `get_oauth_token()`: Fetches access token from OAuth endpoint
   - `check_oauth_refresh()`: Checks and refreshes token before API calls
   - Bearer token authorization for OAuth, Basic auth for API tokens
   - Token expiry tracked with 60-second buffer for safety

### Benefits
- **Security**: OAuth allows granular scopes (logs:network:read, devices:core:read)
- **Automation**: No manual token rotation needed - auto-refresh every hour
- **Flexibility**: Supports both authentication methods seamlessly

---

## 2025-01-14 - API Token Security Enhancement, Legacy Cleanup & Documentation Fix

### Documentation Corrections

1. **Updated API token creation instructions**
   - Fixed incorrect claim about setting specific permissions on API tokens
   - Clarified two token options:
     - API Access Tokens: Simple but have full permissions (cannot be scoped)
     - OAuth Clients: Complex but allow granular scopes like `logs:network:read` and `devices:core:read`
   - Updated error messages, README, .env.example, and CLAUDE.md
   - Now accurately reflects actual Tailscale website functionality

## 2025-01-14 - API Token Security Enhancement & Legacy Cleanup

### Legacy Code Removal

1. **Removed api-token file support**
   - Eliminated fallback to `api-token` file
   - Simplified configuration to use only .env file or environment variables
   - Removed from .gitignore and documentation
   - Reduces configuration complexity and potential security risks

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