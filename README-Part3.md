# Part 3 — Dockerization

## Overview

This section containerizes the Flask tutorial application (Flaskr) with a production-ready Dockerfile and a multi-service `docker-compose.yml`. The web service is the only container exposed to the host; PostgreSQL is accessible only on the internal Docker network.

**SQLite vs PostgreSQL:** The upstream Flask tutorial app uses SQLite via Python's built-in `sqlite3` module — it has no ORM or database abstraction layer. The `docker-compose.yml` provisions a PostgreSQL container with a `DATABASE_URL` environment variable per the assignment requirements, demonstrating multi-service orchestration and internal networking. The application itself continues to use SQLite as shipped upstream. Refactoring the data layer to consume PostgreSQL would be a natural next step but falls outside the scope of this exercise.

---

## Architecture

| Component | Detail |
|---|---|
| Web image | `python:3.12-slim` (multi-stage build) |
| WSGI server | Gunicorn, 2 workers, bound to `0.0.0.0:8000` |
| Database | PostgreSQL 16 Alpine, internal network only |
| Container user | Non-root `appuser` |
| Host port | `8000` (web only; Postgres has no host mapping) |

---

## Files

| File | Location | Purpose |
|---|---|---|
| `Dockerfile` | Repo root | Multi-stage build, non-root user, Gunicorn |
| `docker-compose.yml` | Repo root | Web + PostgreSQL, named volume, healthcheck |
| `.dockerignore` | Repo root | Keeps build context small |
| `docker-entrypoint.sh` | `examples/tutorial/` | Initializes the database, then starts Gunicorn |

---

## Design Decisions

**Multi-stage build.** The builder stage creates a Python venv at `/opt/venv` and installs all dependencies. The runtime stage copies only the finished venv — no compilers, no pip cache, no source code.

**Venv-copy pattern.** The entire `/opt/venv` directory is copied as a single unit. `PATH` is set so that `gunicorn`, `flask`, and all packages are available without activating the venv. This isolates application dependencies from system Python.

**Instance path fix.** When `flaskr` is installed into a venv, Flask resolves the instance directory to `<sys.prefix>/var/flaskr-instance/`. With our venv at `/opt/venv`, that becomes `/opt/venv/var/flaskr-instance/`. The Dockerfile creates this directory during the build (as root) and assigns ownership to `appuser`, preventing the `PermissionError: [Errno 13] Permission denied` crash that occurs when `appuser` tries to create it at runtime.

**Non-root execution.** The container runs as `appuser` via the `USER` directive. Root is only used during the build to install packages and create directories.

**Gunicorn.** Replaces `flask run --debug` as the WSGI server. The `--access-logfile -` flag sends access logs to stdout, which is the correct pattern for Docker logging (`docker compose logs` captures them).

**Port 8000.** Binding to 8000 inside the container avoids requiring root capabilities for privileged ports. Docker Compose maps `8000:8000` on the host.

**ENTRYPOINT + CMD split.** The entrypoint handles database initialization, then `exec "$@"` hands off to CMD (Gunicorn). This allows overriding CMD for debugging (e.g., `docker compose run web sh`).

**`#!/bin/sh` entrypoint.** Slim images may not include bash. POSIX shell is more portable.

**No explicit network block.** Docker Compose creates a default bridge network automatically. Both services join it and can reach each other by service name. Defining an explicit network adds YAML without changing behavior.

**PostgreSQL internal only.** The `db` service has no `ports:` mapping, so it is not reachable from the host or the public internet.

---

## Runbook

### Build and start

```bash
docker compose up --build -d
```

### Verify app responds

```bash
curl -sSf http://localhost:8000/ -o /dev/null && echo "OK" || echo "FAIL"
```

Expected: `OK`

### Verify both containers are running and Postgres is not exposed

```bash
docker compose ps
```

Expected: `web` shows `0.0.0.0:8000->8000/tcp`. `db` shows `5432/tcp` only (no `0.0.0.0` mapping).

### Verify non-root inside web container

```bash
docker compose exec web whoami
```

Expected: `appuser`

```bash
docker compose exec web id
```

Expected: `uid=999(appuser)` (or similar non-zero UID)

### View logs

```bash
docker compose logs -f web
```

Expected: `Initialized the database.` followed by Gunicorn startup and access log lines.

### Stop containers

```bash
docker compose down
```

### Full cleanup (remove volumes)

```bash
docker compose down -v
```

---

## Evidence

> **Reminder:** Replace every `<TODO: ...>` placeholder with actual terminal output before submission.

### Build output

```
$ docker compose up --build -d
<TODO: PASTE build output HERE>
```

### Smoke test

```
$ curl -sSf http://localhost:8000/ -o /dev/null && echo "OK" || echo "FAIL"
<TODO: PASTE result HERE>
```

### Container status

```
$ docker compose ps
<TODO: PASTE output HERE>
```

### Non-root verification

```
$ docker compose exec web whoami
<TODO: PASTE output HERE>

$ docker compose exec web id
<TODO: PASTE output HERE>
```

### Web container logs

```
$ docker compose logs web
<TODO: PASTE output HERE>
```
