# 🚀 Hello World API

Simple REST API dibangun dengan **Go** dan **Echo Framework**, di-deploy ke **Hostinger KVM2 VPS** dengan **GitHub Actions** CI/CD.

**Live URL:** https://api.rifanid.com

---

## 📋 Tech Stack

| Komponen | Detail |
|----------|--------|
| Language | Go 1.23+ |
| Framework | Echo v4 |
| Server | Hostinger KVM2 VPS (Ubuntu 22.04) |
| Domain | api.rifanid.com |
| SSL | Let's Encrypt (Certbot) |
| Reverse Proxy | Nginx |
| Process Manager | Systemd |
| CI/CD | GitHub Actions |

---

## 📁 Project Structure

```
hello-world-api/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions CI/CD pipeline
├── cmd/
│   └── api/
│       └── main.go             # Entry point — setup Echo, routes, middleware
├── internal/
│   └── handler/
│       └── hello.go            # HTTP handlers
├── Dockerfile                  # Multi-stage build
├── .dockerignore
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

---

## 🌐 API Endpoints

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| `GET` | `/hello` | Returns hello world | `{"message":"hello world"}` |
| `GET` | `/health` | Health check | `{"status":"ok"}` |

### Example

```bash
# Hello World
curl https://api.rifanid.com/hello

# Response:
# {"message":"hello world"}

# Health Check
curl https://api.rifanid.com/health

# Response:
# {"status":"ok"}
```

---

## 💻 Local Development

### Prerequisites

- Go 1.23+

### Install & Run

```bash
# Clone repo
git clone git@github.com:rifanid98/hello-world-api.git
cd hello-world-api

# Install dependencies
go mod tidy

# Run server
go run ./cmd/api/main.go

# Server berjalan di http://localhost:8080
```

### Via Makefile

```bash
make run     # Run server
make build   # Build binary ke bin/api
make tidy    # go mod tidy
```

### Test Endpoints

```bash
curl http://localhost:8080/hello
# {"message":"hello world"}

curl http://localhost:8080/health
# {"status":"ok"}
```

---

## 🐳 Docker

### Build & Run

```bash
# Build image
docker build -t hello-world-api .

# Run container
docker run -p 8080:8080 hello-world-api

# Test
curl http://localhost:8080/hello
```

---

## 🚀 Deployment

### Overview

Deployment dilakukan **otomatis** via GitHub Actions setiap kali ada push ke branch `main`.

```
git push origin main
       ↓
GitHub Actions trigger
       ↓
SSH ke Hostinger VPS
       ↓
git pull + go build binary
       ↓
sudo systemctl restart hello-world-api
       ↓
✅ Live di https://api.rifanid.com
```

### CI/CD Pipeline

File: `.github/workflows/deploy.yml`

Workflow melakukan:
1. Checkout code
2. SSH ke VPS menggunakan `appleboy/ssh-action`
3. `git pull origin main` — ambil perubahan terbaru
4. `go build` — compile binary
5. `systemctl restart` — restart service

### GitHub Secrets yang Diperlukan

Konfigurasi di: **Settings → Secrets and variables → Actions**

| Secret | Description |
|--------|-------------|
| `VPS_HOST` | IP address VPS Hostinger |
| `VPS_USER` | SSH username (root) |
| `SSH_PRIVATE_KEY` | Private key untuk SSH ke VPS |

---

## 🖥️ VPS Setup (Sekali Saja)

> Setup manual ini hanya dilakukan **satu kali** saat pertama kali deploy ke VPS baru.

### 1. Install Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git nginx certbot python3-certbot-nginx

# Install Go 1.23
wget https://go.dev/dl/go1.23.6.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.6.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc
source /root/.bashrc
go version
```

### 2. Clone & Build

```bash
sudo mkdir -p /opt/hello-world-api/bin
cd /opt/hello-world-api
git clone git@github.com:rifanid98/hello-world-api.git .

export PATH=$PATH:/usr/local/go/bin
CGO_ENABLED=0 go build -ldflags="-w -s" -o bin/server ./cmd/api
```

### 3. Systemd Service

Buat file `/etc/systemd/system/hello-world-api.service`:

```ini
[Unit]
Description=Hello World Go API (Echo)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/hello-world-api
ExecStart=/opt/hello-world-api/bin/server
Restart=always
RestartSec=3
Environment=PORT=8080

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable hello-world-api
sudo systemctl start hello-world-api
```

### 4. DNS Record

Di **Hostinger Panel → DNS Zone → rifanid.com**, tambahkan:

| Type | Name | Value |
|------|------|-------|
| `A` | `api` | `<VPS_IP>` |

### 5. Nginx Reverse Proxy

Buat file `/etc/nginx/sites-available/api.rifanid.com`:

```nginx
server {
    listen 80;
    server_name api.rifanid.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/api.rifanid.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 6. SSL — Let's Encrypt

```bash
sudo certbot --nginx -d api.rifanid.com
```

Certbot otomatis mengupdate konfigurasi Nginx dan setup HTTPS.

### 7. SSH Key untuk GitHub Actions

```bash
# Generate key
ssh-keygen -t ed25519 -f ~/.ssh/github_actions -N ""

# Authorize di VPS
cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys

# Copy private key → paste ke GitHub Secret SSH_PRIVATE_KEY
cat ~/.ssh/github_actions
```

### 8. Firewall

```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

---

## 🔧 Troubleshooting

```bash
# Cek status service
sudo systemctl status hello-world-api

# Lihat log service secara live
sudo journalctl -u hello-world-api -f

# Cek log Nginx
sudo tail -f /var/log/nginx/error.log

# Restart service
sudo systemctl restart hello-world-api

# Cek apakah app berjalan di port 8080
sudo ss -tlnp | grep 8080
```

---

## 📄 License

MIT

