# Part 5 — CI/CD Automation (GitHub Actions)

## Overview
GitHub Actions workflow that runs on every push and pull request to the takehome and main branches.

## What the Pipeline Does
1. **Test job**: Checks out code, installs Python 3.12, installs tutorial dependencies, runs pytest
2. **Docker-build job** (runs only if tests pass): Builds Docker image, starts container, verifies it responds on port 8000

## Pipeline Behavior
- Tests fail → pipeline fails, Docker build is skipped
- Tests pass → Docker image is built and verified
- Triggers on: push and pull_request to takehome and main branches

## Workflow File
`.github/workflows/ci.yml`

## Verification
- Actions tab: https://github.com/AshkanCodes/flask/actions
- CI #1: green checkmark, all jobs passed
