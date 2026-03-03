# Part 2 — Networking & Security

## Subnet Calculation

Given IP: 192.168.50.34/28

| Property | Value |
|---|---|
| Subnet mask | 255.255.255.240 |
| Network address | 192.168.50.32 |
| Broadcast address | 192.168.50.47 |
| Usable host range | 192.168.50.33 - 192.168.50.46 |
| Usable hosts | 14 |

A /28 mask leaves 4 host bits (16 addresses, minus network and broadcast = 14 usable).

---

## Exposing Only Port 80 Publicly

Configure at two layers:

**Cloud security group:** Allow inbound TCP 80 from 0.0.0.0/0, allow TCP 22 from your IP only, default deny all else.

**Host firewall (ufw):**
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

---

## Firewall: Deny All Other Inbound

Principle: default-deny, then explicitly allow only what is needed.
```bash
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 22/tcp
sudo ufw enable
sudo ufw status numbered
```

---

## Troubleshooting: Service Unreachable Externally but Works Locally

1. **Check bind address**: ss -ltnp - verify 0.0.0.0 not 127.0.0.1
2. **Check host firewall**: ufw status - confirm port allowed
3. **Check cloud security group**: verify inbound rule exists for the port
4. **Verify routing and public IP**: confirm VM has public IP (curl ifconfig.me)
5. **Test from outside**: curl -v http://PUBLIC_IP:PORT - timeout means firewall, refused means nothing listening
