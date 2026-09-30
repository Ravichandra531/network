# Phase 1 failure demonstrations (screenshot each into evidence/08-failures/, then restore)
| # | Break | Observe | Why |
|---|---|---|---|
| 1 | `sudo networksetup -setdnsservers Wi-Fi 192.168.1.99` | dig times out, ping to IP works | DNS and IP are independent |
| 2 | Point host-record at Mac 3's IP, restart dnsmasq, flush cache | Resolves, but connection refused / cert mismatch | DNS is a directory |
| 3 | Stop Backend A | All requests served by B | nginx skips failed upstream |
| 4 | Stop both backends | 502 Bad Gateway; error.log: connect() failed (61) | Edge OK, backend down |
| 5 | `nc -vz <MAC2_IP> 444` | Refused (RST) | Ports separate from IPs |

Restore: `sudo networksetup -setdnsservers Wi-Fi <MAC1_IP>`, fix record, restart services.
Diagnosis order: DNS -> TCP -> TLS -> Application (see scripts/diagnose.sh).
