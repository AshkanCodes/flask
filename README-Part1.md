# Part 1 — Linux & Application Setup

## Overview

This section demonstrates running the [Flask tutorial application](https://github.com/pallets/flask/tree/main/examples/tutorial) locally on Linux under a non-root user, with full command documentation, port verification, and network binding explanation.

**Environment:**

| Detail | Value |
|---|---|
| OS | Ubuntu 24.04 LTS (ARM64) |
| Host | UTM virtualization on macOS (Apple M4 Pro) |
| Python | 3.12.3 |
| Fork | [AshkanCodes/flask](https://github.com/AshkanCodes/flask.git) |
| Branch | `takehome` |

---

## Non-Root User Verification
```bash
whoami
# Expected: your username (e.g., linux)

id -u
# Expected: 1000 (or any non-zero UID)
```

---

## Prerequisites
```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip ca-certificates curl
```

---

## Repository Setup
```bash
mkdir -p ~/src && cd ~/src
git clone https://github.com/AshkanCodes/flask.git
cd flask
git checkout -b takehome
cd examples/tutorial
```

---

## Virtual Environment & Dependencies
```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -U pip wheel
python3 -m pip install -e ../..
python3 -m pip install -e .
```

---

## Running the Application
```bash
flask --app flaskr init-db
flask --app flaskr run --debug
```

The server starts on http://127.0.0.1:5000 by default.

---

## Port Verification
```bash
sudo ss -ltnp | grep -E ':5000'
```

Expected output:
```
LISTEN  0  128  127.0.0.1:5000  0.0.0.0:*  users:(("python3",pid=XXXX,fd=Y))
```

---

## Smoke Test
```bash
curl -sSf http://127.0.0.1:5000/ -o /dev/null && echo "OK" || echo "FAIL"
```

---

## Binding Address: 127.0.0.1 vs 0.0.0.0

**127.0.0.1** binds to loopback only. Only local processes can reach the app.

**0.0.0.0** binds to all interfaces. Any host that can route to the machine can reach the app. This requires firewall rules and security groups when used.

For local development, 127.0.0.1 is the safe default. Binding to 0.0.0.0 should be intentional and paired with appropriate network controls.

---

## Cleanup
```bash
deactivate
```
