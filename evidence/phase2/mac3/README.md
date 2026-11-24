# Phase 2 submission · Mac 3

These are redacted excerpts from the Mac 3 contribution collected on 2026-11-24. Role labels replace private IP addresses; `<app-host>` replaces the project hostname. Protocol results, request order and relative timing are retained. They are not new test runs. Raw captures, screenshots and account-specific settings remain private.

- **A · Backup DNS.** The two project DNS packets show Mac 4 querying Mac 3 and receiving the current main-edge address, with TTL 30 and 4.184 ms query/response time. [Decoded packet excerpt](A-backup-dns-packets.tsv). This exchange contains no HTTPS or backend traffic.
- **DNS consistency finding.** Direct UDP and TCP backup checks succeeded; the primary returned the old edge address at collection time. [Direct answers](DNS-resolver-answers.txt). This historical mismatch is not a claim about the team's current state or a completed failover test.
- **D · Backend A baseline.** A loopback request returned HTTP 200, `X-Backend: A` and status `ok`. [HTTP excerpt](backend-a-status.txt). It does not prove remote access or nginx HA.
- **Configuration validation.** Original private DNS and prepared PF/env files passed static checks. [Validation summary](configuration-checks.txt). Redacted references have separate parse checks described there. Active PF enforcement and rollback were not verified.

[Mac 3 ordered guide, findings and report notes](../../../docs/mac3-phase2.md) · [Configuration references](../../../configs/mac3/env.sh.example)

Still required: primary-down ordinary client success, TTL expiry/flush runs, firewall allowed/blocked/rollback tests, backend failure/recovery, edge migration/restoration, and the actual faculty troubleshooting challenge. Do not mark Extensions A–F complete from these excerpts alone.
