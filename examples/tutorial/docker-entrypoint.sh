#!/usr/bin/env bash
set -e

# Initialize the app DB (SQLite, as in the Flask tutorial)
flask --app flaskr init-db

# Run the CMD (gunicorn)
exec "$@"
