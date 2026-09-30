# Wireshark cheat sheet (capture on a client that is NOT Mac 1, interface en0)
Capture filter: `host <MAC1_IP> or host <MAC2_IP>`
Flush DNS first: `./scripts/flush-dns.sh`
Force TLS1.2 to see the cert: `curl -sv --tlsv1.2 --tls-max 1.2 https://app.team1.test/api/status`

| Evidence | Display filter |
|---|---|
| DNS | `dns` |
| TCP handshake | `tcp.flags.syn==1 && tcp.port==443` |
| TLS handshake | `tls.handshake` |
| Encrypted data | `tls.record.content_type==23` |
| Seq/Ack | Statistics -> Flow Graph -> TCP flows |

Decrypt (optional): `export SSLKEYLOGFILE=~/tls-keys.log`, then set it in Wireshark -> Preferences -> Protocols -> TLS.
Save: evidence/07-wireshark/full-flow.pcapng (TLS1.2) and tls13.pcapng
