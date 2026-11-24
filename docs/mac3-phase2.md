# Phase 2 · Mac 3 contribution

Mac 3 owns Backend A, backup DNS, the controlled DNS cache helper, its backend firewall policy and packet evidence. This contribution follows the repository's `configs/mac2/` and `evidence/phase2/mac2/` layout. It reuses [backend/backend.py](../backend/backend.py) and the existing [backend launcher](../scripts/start-backend.sh); there is no duplicate backend implementation.

## Public references and latest addresses

The configuration files under [configs/mac3](../configs/mac3/env.sh.example) are redacted references. `192.0.2.*`, `example.test` and `/path/to/` replace private addresses, project names and account paths. They cannot be installed unchanged. The evidence excerpts explicitly label substitutions. Original packet captures, screenshots and real network settings remain in the private contribution repository.

**Before every session, obtain the latest IPv4 address from every Mac.** On each Mac, discover the Wi-Fi interface and report its current address:

```bash
WIFI_IF=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
printf 'Wi-Fi interface: %s\n' "$WIFI_IF"
ipconfig getifaddr "$WIFI_IF"
```

Wait for all four members to confirm their role mappings. Synchronize their local env files and the existing `config/env.sh` before using repository scripts. Save deployment copies outside Git, for example `~/cn-phase2/`, and reload the env in every open project Terminal. Refresh DNS listeners, primary and backup records, baseline records, upstream addresses, PF allowlists and cache forwarding targets as applicable. Sourcing an env does not rewrite any of those configuration files or reload a running service.

The Mac 3 examples retain the repository's backend ports 3001/3002. The redacted Mac 2 nginx references use illustrative upstream ports 9001/9002. Before deployment, all members must agree on the actual ports and apply them consistently to the backend launch, nginx and PF files.

## Required process order

Do one row at a time. The recorder saves evidence before the team moves to the next row.

| Order | Owner and work | Wait condition / handoff |
| --- | --- | --- |
| 1 | All Macs confirm latest IPs, synchronize local settings and save service/DNS/PF backups. | Wait for all four confirmations. |
| 2 | Mac 1 proves primary DNS; Mac 3 and Mac 4 prove A and B; Mac 2 proves nginx HTTPS and healthy A/B routing. | All clients must trust the team CA. Stop if Phase 1 checks fail. |
| 3 | Mac 1 confirms normal app/API records. Mac 3 prepares backup DNS and validates it before restart. | Wait for primary records, then compare direct UDP/TCP answers from both resolvers. They must agree on the current main edge. |
| 4 | Client owner sets the two project resolvers and starts recording. Mac 1 temporarily stops primary DNS. | Mac 3 keeps backup DNS running. Prove ordinary hostname HTTPS on the client; direct `dig @backup` alone is insufficient. Restore primary before continuing. |
| 5 | Mac 3 starts the separate cache helper on 5354. DNS owners coordinate a test-record change. | Warm the old answer first. Record decreasing TTL, old/new answers, natural expiry and a separate early-flush run. Restore the test record. |
| 6 | Mac 3 and Mac 4 validate and apply their project backend policies using the team's established child-anchor procedure. | Keep backups and the existing PF enable reference locally. Prove Mac 2 allowed, ordinary client blocked, and HTTPS working; then prove rollback. Reapply only when required for later tests. |
| 7 | Client recorder and Mac 2 begin a timestamped HTTPS request series. Mac 3 stops only its own Backend A process. | Wait for recorder readiness before stopping A. Show B-only successful responses, restart A and prove A/B recovery. |
| 8 | Mac 4 proves standby TLS/nginx readiness. Backend owners temporarily authorize the latest standby address. | Wait for standby access to both backends and CA-valid hostname HTTPS before DNS cutover. |
| 9 | Mac 1 and Mac 3 synchronize the app/API cutover records. Client owner records cached and fresh paths. | Show old/new edge overlap and natural TTL convergence. Restore both resolvers to the latest main-edge address. |
| 10 | All Macs verify restoration. Backend owners revoke temporary standby permission after old traffic drains. | Wait until clients converge and standby traffic stops. Update report findings and outstanding tests from actual evidence. |

## Phase 1 readiness check

Run these only after row 1, using the synchronized local env. Run each check from the machine named below and save its output.

1. Mac 1 and the client compare `dig @"$MAC1_IP" "app.$TEAM.test" A` with the latest Mac 2 address.
2. Mac 3 verifies `curl --noproxy '*' --fail --connect-timeout 3 --max-time 10 -i "http://127.0.0.1:$PORT_A/api/status"` returns HTTP 200 and `X-Backend: A`. Mac 4 does the equivalent for B and `$PORT_B`.
3. Mac 2 verifies direct HTTP access to both current backend addresses and ports, then validates its active nginx config.
4. A client uses ordinary system DNS and trusted TLS: `curl --noproxy '*' --fail --connect-timeout 3 --max-time 15 -i "https://app.$TEAM.test:$HTTPS_PORT/api/status"`. Repeat to record A and B through the edge.

Do not use `-k` or `--resolve` as proof of this ordinary client path. A local A success cannot establish remote edge connectivity. Continue to Phase 2 only after the team records a healthy shared baseline.

## Mac 3 replay notes

If A is not already running, start it from the repository root after refreshing `config/env.sh`:

```bash
bash scripts/start-backend.sh A
```

Keep its Terminal identifiable so the failure test stops only that process. Do not use a broad `killall python3` command.

Edit private copies of the DNS references with the latest addresses and real team zone. Change `conf-file` to the absolute path of the private `records.conf`, then syntax-check with `"$(brew --prefix)/opt/dnsmasq/sbin/dnsmasq" --test --conf-file="$HOME/cn-phase2/dnsmasq-backup.conf"` before using the team's service restart procedure. Check both UDP and TCP 53 from another Mac. The independent backup uses local records; it must keep answering the project zone when primary DNS is down.

The helper on 5354 is a separate foreground dnsmasq process using `client-cache.conf`. It forwards the project zone to Mac 1 and provides a controlled cache for TTL experiments. Direct resolver answers and this helper do not prove macOS application cache behavior; record the normal client path separately.

Validate a private prepared PF file with `pfctl -nf "$HOME/cn-phase2/backend-strict.pf"`. This parses only. Loading the policy requires the established project child anchor to be reachable from the active root ruleset. Do not load this child file at the root, replace `/etc/pf.conf`, flush system anchors or obtain another PF enable reference just to update an edge address. Preserve the existing token locally and collect active table/rule counters plus allowed, blocked and restoration tests. Use fresh TCP connections for policy tests; existing PF states can retain earlier permissions. This public package contains no claim that the prepared correction was installed.

## Results, findings and report contribution

See the [evidence index](../evidence/phase2/mac3/README.md) for measured results and their limits.

| Extension / review item | Mac 3 evidence available | Evidence still needed for a complete demonstration |
| --- | --- | --- |
| A · Backup DNS | Mac 4 query/Mac 3 reply, plus direct backup UDP/TCP success | Primary-down event plus ordinary client HTTPS through backup |
| B · TTL | Advertised TTL 30 and helper configuration | Cache countdown, old/new comparison, natural expiry and early flush |
| C · Isolation | Prepared source allowlist and syntax validation | Active allowlist/counters, edge allowed, client blocked and rollback |
| D · HA | Local Backend A HTTP 200 | Coordinated A stop, B-only success and A/B recovery through nginx |
| E · Migration | Backup/cache references and coordination order | Standby authorization, cutover, cached/fresh paths and restoration |
| F · Troubleshooting | Historical primary/backup answer mismatch isolated | Actual faculty challenge, layer diagnosis, correction and retest |
| Report and viva | Changes, measured results, limits and lessons below | Merge other members' evidence; each student explains the whole path |

At Mac 3 collection time, direct primary DNS returned an old edge address while backup DNS returned the confirmed current edge. Local env, baseline and PF source copies also contained stale edge addresses. Prepared private copies corrected these references, but collection did not apply them to running services. Active PF inspection required administrator authentication and was not verified. These are historical findings; Mac 2's evidence may reflect a different collection time. Recheck both resolvers now before calling the system healthy.

The lesson is to treat the four-Mac address map and generated configuration as coordinated state: update both DNS owners, refresh service listeners and allowlists, then test the ordinary request path. DNS reachability, trusted TLS, HTTP health and HA are separate observations. A TTL value by itself is not a cache-expiry experiment. The faculty challenge must be documented as actually performed, rather than relabeling this preparation finding.
