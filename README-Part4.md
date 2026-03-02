# Part 4 — AWS Cloud Deployment (EC2 + Docker)

## Overview
Deployed the Dockerized Flask tutorial app (from Part 3) to an AWS EC2 instance. The app is publicly accessible over HTTP on port 80 using SSH key-based authentication.

## Architecture
- EC2 instance (t3.micro, Ubuntu 24.04, x86_64, us-east-2)
- Docker Compose runs web (port 80->8000) and db (port 5432 internal only)
- Security Group allows only SSH (22) and HTTP (80)

## Security Group Rules
| Type | Port | Source     | Purpose            |
|------|------|-----------|--------------------|
| SSH  | 22   | 0.0.0.0/0 | Remote access      |
| HTTP | 80   | 0.0.0.0/0 | Public web traffic |

All other inbound traffic denied by default.

## EC2 Instance Details
- Instance ID: i-022d9de2ac41144c3
- Instance type: t3.micro (Free Tier)
- AMI: Ubuntu Server 24.04 LTS
- Key pair: flask-key (RSA, .pem)
- Public IP: 18.119.107.228

## ARM vs x86 Decision
Local dev was ARM (UTM on Mac M4 Pro). EC2 Free Tier is x86_64. Docker image is built directly on EC2 to avoid cross-compile issues.

## Deployment Steps
1. Launch EC2 Ubuntu 24.04 instance with SSH+HTTP security group
2. SSH in: ssh -i flask-key.pem ubuntu@18.119.107.228
3. Install Docker: sudo apt update && sudo apt install -y docker.io docker-compose-v2
4. Clone repo: git clone -b takehome https://github.com/AshkanCodes/flask.git
5. Change port to 80: sed -i 's/8000:8000/80:8000/' docker-compose.yml
6. Deploy: docker compose up --build -d

## Verification
- docker compose ps: db healthy (internal), web up (80->8000)
- docker compose exec web whoami: appuser
- curl http://localhost/: OK
- Browser http://18.119.107.228: Flaskr app loads

## Database Note
Same as Part 3: app uses SQLite. Postgres container present for requirement compliance only.

## Screenshot
See screenshots/part4-app-running.png
