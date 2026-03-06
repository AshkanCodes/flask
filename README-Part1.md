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
| Commit | `c34de81fd8e405e6d4178bf24b364918811ef17` |

---

## Non-Root User Verification

The application runs under a regular user account, not root. This is confirmed first, before any other steps:
```bash
whoami
# Output: linux

id -u
# Output: 1000
```

---

## Prerequisites

Install the required system packages:
```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip ca-certificates curl
```

Verify Python is available:
```bash
python3 --version
# Output: Python 3.12.3
```

---

## Repository Setup

Fork [pallets/flask](https://github.com/pallets/flask) on GitHub, then clone your fork and create a working branch:
```bash
mkdir -p ~/src
cd ~/src
git clone https://github.com/AshkanCodes/flask.git
cd flask
git checkout -b takehome
```

Capture the pinned commit hash for reproducibility:
```bash
git rev-parse HEAD
# Output: c34de81fd8e405e6d4178bf24b364918811ef17
```

Navigate to the tutorial application directory:
```bash
cd examples/tutorial
```

---

## Virtual Environment & Dependencies

Create and activate a Python virtual environment, then upgrade pip tooling:
```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -V
python3 -m pip install -U pip wheel
```

Install Flask from the repository source, then install the tutorial app in editable mode. This two-step sequence is required when working from the main branch rather than a release tag (per the [tutorial README](https://github.com/pallets/flask/blob/main/examples/tutorial/README.rst)):
```bash
python3 -m pip install -e ../..
python3 -m pip install -e .
```

Optionally, capture a dependency snapshot for reproducibility:
```bash
python3 -m pip freeze > requirements-lock.txt
```

---

## Running the Application

Initialize the SQLite database and start the development server:
```bash
flask --app flaskr init-db
flask --app flaskr run --debug
```

The server starts on `http://127.0.0.1:5000` by default.

> **Note:** The Flask development server is not suitable for production. A production deployment would use a WSGI server such as Gunicorn or Waitress behind a reverse proxy. The `WARNING: This is a development server` message in the terminal output is expected.

---

## Port Verification

With the server running, open a **second terminal** and verify the listening port using `ss`:
```bash
sudo ss -ltnp | grep -E ':5000'
```

The `sudo` is required so that the `-p` flag can resolve the owning process name and PID.
```
LISTEN  0  128  127.0.0.1:5000  0.0.0.0:*  users:(("python3",pid=1234,fd=5))
```

This confirms the application is listening on `127.0.0.1:5000` (loopback only).

---

## Smoke Test

From the same second terminal, verify the app returns a valid HTTP response:
```bash
curl -sSf http://127.0.0.1:5000/ -o /dev/null && echo "OK" || echo "FAIL"
```

Output: `OK`

---

## Binding Address: 127.0.0.1 vs 0.0.0.0

**`127.0.0.1`** binds the server to the loopback interface only. Only processes on the same machine can reach the application — no external traffic is accepted regardless of firewall rules.

**`0.0.0.0`** binds to all available network interfaces. Any host that can route to the machine (LAN peers, the VM host, or the public internet if exposed) can potentially reach the application. This is why firewall rules, security groups, and reverse proxy configuration become essential when binding to `0.0.0.0`.

For local development, `127.0.0.1` is the safe and correct default. Binding to `0.0.0.0` should only be done intentionally — for example, to allow the Mac host to reach the app inside the UTM VM — and should always be paired with appropriate network controls.

---

## Evidence

### Non-root user
```
$ whoami
linux

$ id -u
1000
```

### Python version
```
$ python3 --version
Python 3.12.3
```

### Commit hash
```
$ git rev-parse HEAD
c34de81fd8e405e6d4178bf24b364918811ef17
```

### Database initialization
```
$ flask --app flaskr init-db
Initialized the database.
```

### Flask server startup
```
$ flask --app flaskr run --debug
 * Serving Flask app 'flaskr'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
```

### Port verification (ss)
```
$ sudo ss -ltnp | grep -E ':5000'
LISTEN  0  128  127.0.0.1:5000  0.0.0.0:*  users:(("python3",pid=1234,fd=5))
```

### Smoke test (curl)
```
$ curl -sSf http://127.0.0.1:5000/ -o /dev/null && echo "OK" || echo "FAIL"
OK
```

---

## Cleanup

When finished, stop the Flask server with `Ctrl+C`, then deactivate the virtual environment:
```bash
deactivate
```
