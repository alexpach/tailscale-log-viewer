# RESEARCH.md

## 2025-01-13 - Critical Bugs Investigation

### 1. IPv6 Address Filtering with Special Characters

**Issue**: Concern that IPv6 addresses with brackets might break jq parsing

**Research**:
- Tested various special characters in filters: `[]`, `{}`, `"`, `'`, `$`, `*`, `?`, `|`, `&`, `;`
- Found that jq properly handles these characters when passed correctly
- The script already escapes quotes properly in the jq filter construction

**Conclusion**: ✅ No issues found - special characters are properly handled

### 2. Filter Matching Precision

**Issue**: Using `contains()` in jq filters causes false positives
- Filtering for "10.0.0.1" also matches "10.0.0.10", "10.0.0.100", "210.0.0.1"
- Filtering for "server1" also matches "server10", "server123"

**Root Cause Analysis**:
1. The script uses `contains()` function for all filter matching
2. This is substring matching, not exact matching
3. Particularly problematic for IP addresses

**Solution Implemented**:
- Created `is_ip_address()` helper function to detect IPv4/IPv6 addresses
- Use exact match (`==`) for IP addresses
- Continue using `contains()` for machine names (for flexibility)

**Deeper Issue Discovered**:
- The filtering operates at the log entry level, not the flow level
- When a log entry has multiple traffic flows and one matches, ALL flows are returned
- This is a fundamental design issue that requires refactoring
- Added to TODO as future work

### 3. Debug Mode Token Security

**Issue**: Concern that debug mode might expose API tokens

**Research**:
- Examined all debug_log() calls in the script
- Checked how curl commands are constructed
- Token is passed via curl's `-u` flag: `curl -u "$api_token:"`
- Debug output doesn't include the actual curl command with token

**Conclusion**: ✅ Tokens are properly protected - never shown in debug output

### Test Coverage Created

1. **test/test_critical_bugs.sh** - Comprehensive test for all three issues
2. **test/test_filter_precision.sh** - Specific tests for filter matching precision
3. **test/test_exact_match.sh** - Focused test for exact IP matching

### References
- jq Manual (contains/test functions): https://jqlang.github.io/jq/manual/
- Bash pattern matching: https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html

---

## 2025-01-14 - API Token Security in Bash

### Issue: get_api_token() function uses echo

**Current Implementation**:
```bash
get_api_token() {
    echo "$TAILSCALE_API_TOKEN"  # or cat api-token
}
api_token=$(get_api_token)
```

**Security Concerns**:
1. **Process listing**: Echo might briefly expose token in process list
2. **Shell tracing**: If bash -x is enabled, token appears in debug output
3. **Command history**: Token might be logged if used in commands

**Research on Alternatives**:

1. **Global Variable Approach**:
   - Set a global variable instead of echoing
   - Pros: No subprocess, no echo
   - Cons: Pollutes global namespace

2. **File Descriptor Approach**:
   - Pass token through file descriptor
   - Pros: Most secure, no process exposure
   - Cons: More complex

3. **Environment Variable Only**:
   - Require token to be in environment
   - Pros: Simple, standard practice
   - Cons: Less flexible

**Best Practice Analysis**:
- Current implementation is actually relatively safe because:
  - Token is captured immediately via command substitution
  - Never passed as command-line argument
  - curl uses `-u` flag which puts token in HTTP header, not command line

**Recommendation**:
The current approach is acceptable but could be improved by:
1. Using a global variable to avoid subprocess
2. Adding warnings about not using `set -x` with sensitive operations
3. Ensuring token is never logged or displayed

### References
- OWASP Bash Security: https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html
- Bash Security Best Practices: https://github.com/anordal/shellharden/blob/master/how_to_do_things_safely_in_bash.md