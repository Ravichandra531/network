# Architecture (Phase 1)

## Topology
```
            Wi-Fi / LAN (router or hotspot)
 ┌────────────┬─────────────┬─────────────┬─────────────┐
 Mac 1        Mac 2         Mac 3         Mac 4
 DNS+Client   Edge nginx    Backend A     Backend B+Client
 dnsmasq :53  :443 TLS+LB   :3001         :3002
```

## IP / Service inventory (fill in)
| Mac | Role | IP | Interface | MAC addr | Service | Port | Cloud equivalent |
|---|---|---|---|---|---|---|---|
| 1 | DNS + client | | en0 | | dnsmasq | 53/UDP | Route 53 |
| 2 | Edge / LB | | en0 | | nginx | 80,443/TCP | ALB / CDN edge |
| 3 | Backend A | | en0 | | backend.py | 3001/TCP | App instance A |
| 4 | Backend B + client | | en0 | | backend.py | 3002/TCP | App instance B |

Subnet/prefix: ____  Gateway: ____

## Request flow
1. Client asks Mac 1 for app.team1.test (DNS, UDP/53) -> gets Mac 2's IP
2. TCP 3-way handshake to Mac 2:443
3. TLS handshake (ClientHello, ServerHello, Certificate, key exchange, Finished)
4. Encrypted HTTP request; nginx terminates TLS, picks a backend (round-robin)
5. Backend replies with X-Backend header; nginx returns it to client

## Layer mapping
| Protocol | Layer |
|---|---|
| DNS, HTTP | Application |
| TLS | Session/Transport (between app and TCP) |
| TCP/UDP | Transport |
| IP | Network |
| Wi-Fi/Ethernet | Link |
