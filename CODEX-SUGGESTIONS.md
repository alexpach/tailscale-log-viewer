Bugs / Mismatches

- -v/--verbose is documented (README, help, troubleshooting) but not implemented in code.
- format_date_rfc3339 is defined but unused.
- test/test_validation_only.sh uses timeout which isn’t available on macOS by default; add fallback to gtimeout or skip on Darwin.

Correctness / Robustness

- HTTP errors are not reliably detected: curl -s does not fail on 4xx/5xx. Use curl -fsS --retry 3 --retry-connrefused and handle 429 (Retry-After).
- Device mapping uses only the first address (.addresses[0]), which can miss mappings:
  - Map all addresses for each device to support both 100.x IPv4 and Tailscale IPv6 (fd7a:).
- Summary machine-name resolution only checks IPv4 flows (startswith("100.")):
  - Include Tailscale IPv6 prefix in detection; use the same IP→name mapping for IPv6.
- --src/--dst filter substring matching can cause false positives:
  - Prefer exact or anchored matches; consider supporting regex with a --regex flag to opt-in.
- Filtering logic builds jq queries via string concatenation; escaping errors can surface for values with special chars (e.g., [ ] : in IPv6).
  - Consider passing patterns via --arg to jq and using jq functions like test() safely.

Performance

- Multiple heavy jq passes; some parsing/aggregation duplicated between table/compact/summary.
  - Factor shared jq into reusable jq functions or use a single pass where possible.
- Device fetch on every run adds latency:
  - Cache devices in ~/.cache/ts-logs/devices.json with TTL (e.g., 5–10 minutes) and ETag support if available.
- Name resolution currently done per-line in Bash; prefer enriching via jq to reduce Bash work.

Portability

- macOS compatibility is good overall (gdate fallbacks present), but tests use timeout.
  - Add a tiny shim: use gtimeout if available, otherwise skip or reduce test duration.
- README claims Bash v4+, macOS default is 3.2. Validate features used or provide guidance to install modern Bash.

UX / CLI

- Add --version, --no-resolve-names (skip device fetch for speed), --no-service-names, --follow (polling tail), and --output FILE.
- More explicit errors for HTTP 401/403 (permissions), 429 (rate limited), 404 (tailnet or endpoint typo), with suggested fixes.

Testing / CI

- Add an offline mode using fixture JSON files for stable tests (formatting, filtering, summary).
- Provide make test to run offline tests and numeric validation tests.
- Add GitHub Actions with:
  - shellcheck and shfmt (format check).
  - Offline tests (no real API calls).
- Keep online integration tests opt-in using env (TAILSCALE_API_TOKEN, TAILNET) and a skip-by-default job.

Security

- Never log tokens; ensure verbose mode redacts tokens/URLs.
- Document token scopes and storage (done) and optionally support system keychains (macOS keychain, pass/gnome-keyring).
- Consider --mask-ips to redact IPs in output.

Code Organization

- Split the script:
  - lib/api.sh (curl, error handling, caching).
  - lib/format.sh (table/compact/summary helpers and byte/unit formatting).
  - lib/filter.sh (jq filters and safe arg passing).
  - lib/util.sh (date parsing, logging, signal traps).
  - bin/ts-logs (CLI arg parsing and orchestration).
- Add traps for SIGINT/SIGTERM to exit cleanly and flush partial output.

Documentation

- Align status (Beta vs Production) and remove options not implemented yet (or implement them).
- Note macOS Bash version caveat and jq hard requirement for table/compact/summary.
- Add a short section on API rate limits and expected behavior.
- Include a small sample JSON payload to demonstrate offline usage and tests.

Quick Wins

- Implement -v/--verbose and a log() helper.
- Map all device addresses, and update summary to resolve IPv6.
- Make curl robust: -fsS --retry 3 with explicit HTTP error handling.
- Add a minimal offline test fixture and a CI workflow running shellcheck + offline tests.

If you’d like, I can:

- Implement the --verbose flag, curl error handling, and service-name fixes.
- Add all-address device mapping and IPv6 name resolution in summary.
- Add an offline test fixture and a basic GitHub Actions CI.
