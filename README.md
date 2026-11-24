Private Network Service Platform 

## Layout
- `config/env.sh` set your team name, IPs, ports (edit first)
- `config/*.template` dnsmasq and nginx templates
- `backend/backend.py` REST backend (stdlib only)
- `scripts/` helpers
- `docs/` architecture + failure demos
- `evidence/` screenshots and captures

## Quick start
1. Every Mac: clone repo, edit `config/env.sh` (same values on all Macs).
2. Mac 1 (DNS): `./scripts/render-configs.sh`, copy `build/dnsmasq.conf` into `$(brew --prefix)/etc/dnsmasq.conf`, `sudo brew services start dnsmasq`.
3. Mac 3: `./scripts/start-backend.sh A`. Mac 4: `./scripts/start-backend.sh B`.
4. Mac 2 (edge): `./scripts/make-certs.sh`, `./scripts/render-configs.sh`, copy `build/team1.conf` to `$(brew --prefix)/etc/nginx/servers/`, then `sudo nginx -t && sudo brew services start nginx`.
5. Clients: copy `ca.crt` from Mac 2, run `./scripts/trust-ca-client.sh ca.crt`, set DNS to Mac 1's IP.
6. Test: `./scripts/test-lb.sh`, `./scripts/diagnose.sh`.

If you use 8080/8443, set them in `config/env.sh` and add the port to URLs (e.g. `https://app.team1.test:8443`).
Never commit `*.key`.
# network

## Phase 2 · Mac 3

- [Mac 3 setup order, report notes and remaining tests](docs/mac3-phase2.md)
- [Redacted configuration references](configs/mac3/env.sh.example)
- [Mac 3 evidence and its limits](evidence/phase2/mac3/README.md)

Before deployment, use the latest IP addresses from **all four Macs** and synchronize every member's local settings. The Mac 3 references contain documentation addresses, not live lab settings.
