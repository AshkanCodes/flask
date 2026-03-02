# ---- Build stage ----
FROM python:3.12-slim AS builder

WORKDIR /build

COPY . .

RUN pip install --no-cache-dir . examples/tutorial/ gunicorn

# ---- Production stage ----
FROM python:3.12-slim

RUN useradd --create-home --no-log-init appuser

COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn
COPY --from=builder /usr/local/bin/flask /usr/local/bin/flask

COPY examples/tutorial/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /usr/local/var/flaskr-instance && chown appuser:appuser /usr/local/var/flaskr-instance

USER appuser
WORKDIR /home/appuser

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "flaskr:create_app()"]
