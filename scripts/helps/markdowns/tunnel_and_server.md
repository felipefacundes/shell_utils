# Complete Guide: Exposing Local Services with Tunnels (Free Alternatives to Ngrok)

## 📋 Index
- [Overview](#overview)
- [Tools Comparison Table](#-tools-comparison-table)
- [Selection Guide](#-ideal-tool-selection-guide)
- [Environment Preparation](#-environment-preparation)
- [Practical Tutorials](#-practical-tutorials)
- [Common Use Cases](#-common-use-cases)
- [Best Practices and Security](#-best-practices-and-security)
- [FAQ](#-frequently-asked-questions)
- [Additional Resources](#-additional-resources)

## Overview

This guide brings together free and open-source tools for exposing local services on the internet. These solutions are ideal for developers who need to test webhooks, demonstrate projects, access home servers, or share APIs in development.

## 🛠️ Tools Comparison Table

| Name | Price (Free Tier) | Installation | Main Advantage | Supported Protocols | Requires Registration | Highlights |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Cloudflare Tunnel** | Free (50 users) | `cloudflared` binary | **Security and performance** with global network | HTTP/HTTPS, TCP, UDP | Yes | DDoS protection, analytics, web dashboard |
| **localhost.run** | 100% free | Pure SSH | **Zero installation** on client machine | HTTP/HTTPS | No | Direct SSH, stable subdomain |
| **Pinggy** | Free (for testing) | SSH with flags | **Interactive terminal** with debug | HTTP/HTTPS, TCP | No for testing | Real-time traffic inspection |
| **PageKite** | Free (data limit) | Python script | **Complete open-source** | HTTP/HTTPS, TCP | Yes for advanced features | Self-hosting possible, Python-based |
| **Zrok** | Free (self-hosted) | GitHub binary | **Zero-trust architecture** | HTTP/HTTPS, TCP | Yes | Focus on security, full control |
| **bore** | 100% open-source | Cargo/Rust | **Extremely lightweight** | TCP tunneling | No | Rust-based, minimal overhead |
| **Tunnelmole** | Free | NPM or binary | **Direct alternative to ngrok** | HTTP/HTTPS | No | Familiar interface, easy to use |
| **FRP (Fast Reverse Proxy)** | Open-source | Go binary | **High performance** | HTTP/HTTPS, TCP, UDP | No | Own server, highly configurable |
| **SirTunnel** | Free | Docker/Node.js | **Integrated web dashboard** | HTTP/HTTPS | No | Friendly interface, multi-tunnel |
| **LocalXpose** | Free (with limits) | Go binary | **Similar to ngrok** | HTTP/HTTPS, TCP | Yes | Advanced features in free tier |

## 🔍 Ideal Tool Selection Guide

### 1. **What do you need the tunnel for?**
- **Quick, single test** (show to a colleague): → **`localhost.run`**
- **Continuous development/Webhooks**: → **Cloudflare Tunnel** or **Pinggy**
- **Full control/Self-hosting**: → **Zrok** or **FRP**
- **Avoid Node.js**: → **localhost.run** (SSH) or **PageKite** (Python)

### 2. **Technical considerations**
- **Firewall restrictions**: SSH (port 443) usually works better
- **Required performance**: Cloudflare has optimized global network
- **Domain persistence**: Some services offer stable subdomains
- **Protocol support**: Check if you need TCP/UDP besides HTTP

### 3. **Recommendations by scenario**
- **Best overall value**: `localhost.run`
- **Most professional/robust**: Cloudflare Tunnel
- **Simplest for beginners**: Tunnelmole
- **Most control/configuration**: FRP

## 🛠️ Environment Preparation

### Setting Up a Basic Local Server

#### Example Folder Structure:
```bash
demo-project/
├── index.html
├── style.css
├── script.js
├── api/
│   └── data.json
└── images/
    └── logo.png
```

#### Local Server Options:

```bash
#!/bin/bash
# Option 1: Python server (recommended for beginners)
cd ~/demo-project
python3 -m http.server 8080

# Option 2: Python server with specific directory
python3 -m http.server 8080 --directory /path/to/folder

# Option 3: PHP server (if installed)
php -S localhost:8080

# Option 4: Simple Node.js server
npx serve . -p 8080

# Option 5: Server with specific bind
python3 -m http.server 8080 --bind 0.0.0.0  # Accessible by any IP
```

#### Creating a Quick Test Project:
```bash
#!/bin/bash
# Create a basic structure for tests
mkdir my-test && cd my-test

# Create basic files
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Server</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <h1>✅ Server Running!</h1>
    <p>Status: <span class="status">Online</span></p>
    <p>Public URL: <code id="url">Loading...</code></p>
    <script>
        document.getElementById('url').textContent = window.location.href;
    </script>
</body>
</html>
EOF

# Start the server
python3 -m http.server 8080
```

#### Verifying if the Server is Working:
```bash
# Test locally
curl http://localhost:8080

# Or open in browser:
# http://localhost:8080
```

## 🚀 Practical Tutorials

### Tutorial 1: Pinggy (Recommended for Quick Tests)

```bash
#!/bin/bash
# STEP 1: Prepare local server
# Navigate to the folder you want to share
cd ~/my-project
python3 -m http.server 8080

# STEP 2: In ANOTHER terminal, create tunnel
ssh -p 443 -R0:localhost:8080 a.pinggy.io

# STEP 3: Use Pinggy's interactive terminal
# After connecting, you will see:
# 1. Public URL (ex: https://abc123.pinggy.link)
# 2. Press 'i' to see real-time requests
# 3. Press 'h' for help with commands
# 4. Press 't' to see statistics

# TIP: For shorter URL, use:
ssh -p 443 -R0:localhost:8080 a.pinggy.io -- -subdomain=mytest
```

### Tutorial 2: localhost.run (The Simplest)

```bash
#!/bin/bash
# Expose server on port 3000
ssh -R 80:localhost:3000 localhost.run

# With custom subdomain (if available)
ssh -R 80:localhost:3000 ssh.localhost.run

# Expose multiple ports
ssh -R 80:localhost:3000 -R 8080:localhost:8080 localhost.run

# Keep tunnel active even with SSH disconnection
ssh -o ServerAliveInterval=60 -R 80:localhost:3000 localhost.run
```

### Tutorial 3: Cloudflare Tunnel (For Professional Use)

```bash
#!/bin/bash
# 1. Installation
# Linux:
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared

# 2. Authenticate (opens browser for login)
cloudflared tunnel login

# 3. Create tunnel
cloudflared tunnel create my-tunnel

# 4. Configure (edit config.yml file)
# The file will be at ~/.cloudflared/config.yml

# 5. Start tunnel
cloudflared tunnel run my-tunnel

# 6. DNS routing (optional)
cloudflared tunnel route dns my-tunnel subdomain.yourdomain.com
```

### Tutorial 4: Tunnelmole (Alternative to Ngrok)

```bash
#!/bin/bash
# Installation via npm
npm install -g tunnelmole

# Basic usage
tunnelmole 8080

# With specific subdomain
tunnelmole 8080 --subdomain myserver

# To get HTTPS URL
tunnelmole 8080 --https

# Show status
tunnelmole status
```

### Tutorial 5: FRP - Self-hosted (Full Control)

```bash
#!/bin/bash
# ===== ON REMOTE SERVER (VPS) =====
# 1. Download
wget https://github.com/fatedier/frp/releases/download/v0.51.3/frp_0.51.3_linux_amd64.tar.gz
tar -xzf frp_0.51.3_linux_amd64.tar.gz
cd frp_0.51.3_linux_amd64

# 2. Configure server (frps.ini)
cat > frps.ini << EOF
[common]
bind_port = 7000
vhost_http_port = 8080
vhost_https_port = 8443
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = securepassword
token = mysecuretoken
EOF

# 3. Start server
./frps -c frps.ini

# ===== ON YOUR LOCAL MACHINE =====
# 4. Configure client (frpc.ini)
cat > frpc.ini << EOF
[common]
server_addr = YOUR_SERVER_IP
server_port = 7000
token = mysecuretoken

[web]
type = http
local_ip = 127.0.0.1
local_port = 8080
custom_domains = app.yourdomain.com

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
EOF

# 5. Start client
./frpc -c frpc.ini
```

## 💡 Common Use Cases

### 1. **Frontend Development**
```bash
#!/bin/bash
# React/Vue/Next.js
npm run dev  # Port 3000
ssh -R 80:localhost:3000 localhost.run

# With hot reload working
npm run dev & ssh -R 80:localhost:3000 localhost.run
```

### 2. **Webhook and API Testing**
```bash
#!/bin/bash
# Local API in Flask/Django/Express
python app.py  # Port 5000

# In another terminal:
ssh -p 443 -R0:localhost:5000 a.pinggy.io

# Now external webhooks can access:
# https://yourid.pinggy.io/api/webhook
```

### 3. **Access to Administration Tools**
```bash
#!/bin/bash
# Expose Portainer panel (Docker)
docker run -d -p 9000:9000 portainer/portainer
ssh -R 80:localhost:9000 localhost.run

# Home Assistant
ssh -R 80:localhost:8123 localhost.run
```

### 4. **Client Demonstration**
```bash
#!/bin/bash
# Generate production build and serve
npm run build
npx serve -s build -p 8080
cloudflared tunnel --url http://localhost:8080
```

## 🔒 Best Practices and Security

### ⚠️ **Critical Attention**
1. **Never expose production services**
2. **Use authentication on everything** you expose
3. **Limit the time** the tunnel is open
4. **Monitor active connections**
5. **Use HTTPS** whenever possible

### Secure Settings

```bash
#!/bin/bash
# With HTTP basic authentication
# For Python, use:
python3 -m http.server 8080 --username admin --password strongpassword

# For tunnels with authentication
ssh -R 80:localhost:8080 localhost.run --auth "user:password"

# Tunnel with timeout (2 hours)
timeout 7200 ssh -R 80:localhost:8080 localhost.run
```

### Basic Security Script
```bash
#!/bin/bash
# secure_tunnel.sh - Tunnel with basic protections

PORT=${1:-8080}
TIMEOUT=3600  # 1 hour
LOG_FILE="/tmp/tunnel_$(date +%Y%m%d_%H%M%S).log"

echo "Starting secure tunnel on port $PORT"
echo "Log: $LOG_FILE"
echo "Time limit: $TIMEOUT seconds"

# Check if port is in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "ERROR: Port $PORT already in use!"
    exit 1
fi

# Start tunnel with timeout
timeout $TIMEOUT ssh -o ExitOnForwardFailure=yes \
                     -o ServerAliveInterval=30 \
                     -o ServerAliveCountMax=3 \
                     -R 80:localhost:$PORT \
                     localhost.run 2>&1 | tee "$LOG_FILE"

echo "Tunnel closed after $TIMEOUT seconds"
```

### Services that should NEVER be Exposed:
- ✅ **CAN**: Development applications, tests, demonstrations
- ❌ **CANNOT**:
  - SSH from your main machine
  - Production databases
  - Admin panels without authentication
  - Services with known security flaws
  - Anything with sensitive data

## ❓ Frequently Asked Questions

### **Q: My tunnel drops frequently. How to fix?**
**A:** Try these solutions:
```bash
#!/bin/bash
# 1. Use keepalive
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 ...

# 2. Auto-reconnection script
while true; do
    ssh -R 80:localhost:8080 localhost.run
    sleep 5
done

# 3. Use more stable service (Cloudflare)
```
### **Q: Can I use my own free domain?**
**A:** Yes, some options:
1. **Cloudflare Tunnel**: Domains managed by Cloudflare
2. **DuckDNS**: Free dynamic domain
3. **No-IP**: Offers basic free domain

### **Q: How to know which port my app is using?**
**A:**
```bash
# For common web applications:
# React: 3000    Vue: 8080    Angular: 4200
# Flask: 5000    Django: 8000    Express: 3000

# Check used ports:
sudo netstat -tulpn | grep LISTEN
# or
sudo lsof -i -P -n | grep LISTEN
```

### **Q: Does tunnel work behind NAT/router?**
**A:** Yes! That's the main advantage. Tunnels create an outbound connection, bypassing NAT limitations.

### **Q: Is there a bandwidth limit on free plans?**
**A:** Usually yes, but generous:
- **Cloudflare**: ~100GB/month
- **localhost.run**: No known limit
- **Pinggy**: Limited for testing
- **Tunnelmole**: 1GB/month free

## 🚨 Troubleshooting

### Common Problems:

```bash
#!/bin/bash
# 1. "Connection refused" when trying to access URL
# Solution: Check if local server is running
curl http://localhost:8080  # Should return something

# 2. "Port already in use"
# Solution: Change port or kill process
sudo lsof -ti:8080 | xargs kill -9
python3 -m http.server 8081

# 3. SSH repeatedly asks for password
# Solution: Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 4. Tunnel connects but page doesn't load
# Solution: Check firewalls
sudo ufw allow 8080/tcp  # For Ubuntu
```

### Diagnostic Commands:
```bash
#!/bin/bash
# Test basic connectivity
ping -c 4 localhost.run

# Check if port is open locally
nc -zv localhost 8080

# Test tunnel with curl
curl -I https://yourtunnel.pinggy.io

# Monitor connections in real time
watch -n 1 "netstat -an | grep ESTABLISHED"
```

## 📚 Additional Resources

### Useful Complementary Tools

```bash
# 1. Ngrok (popular paid alternative)
# https://ngrok.com/ (has limited free plan)

# 2. Serveo (SSH-based alternative)
ssh -R 80:localhost:8080 serveo.net

# 3. Beeceptor (for API mocking)
# Great for testing webhooks: https://beeceptor.com

# 4. Pipedream (automation + webhooks)
# Allows creating endpoints quickly
```

### Automated Scripts

```bash
#!/bin/bash
# auto_tunnel.sh - Automates tunnel creation
set -e

APP_PORT=${1:-3000}
TUNNEL_TYPE=${2:-localhost}

case $TUNNEL_TYPE in
    "localhost")
        echo "Starting localhost.run on port $APP_PORT"
        ssh -R 80:localhost:$APP_PORT localhost.run
        ;;
    "pinggy")
        echo "Starting Pinggy on port $APP_PORT"
        ssh -p 443 -R0:localhost:$APP_PORT a.pinggy.io
        ;;
    "cloudflare")
        echo "Starting Cloudflare Tunnel"
        cloudflared tunnel --url http://localhost:$APP_PORT
        ;;
    *)
        echo "Unknown type. Use: localhost, pinggy, cloudflare"
        exit 1
        ;;
esac
```

### Basic Monitoring
```python
#!/bin/python
# monitor_tunnel.py
import requests
import time
from datetime import datetime

def monitor_tunnel(url, interval=60):
    """Monitors tunnel status"""
    while True:
        try:
            response = requests.get(url, timeout=10)
            status = "✅ ONLINE" if response.status_code == 200 else "⚠️  PROBLEM"
            print(f"{datetime.now()} - {status} - {url}")
        except Exception as e:
            print(f"{datetime.now()} - ❌ OFFLINE - {url} - Error: {e}")
        
        time.sleep(interval)

if __name__ == "__main__":
    # Use: python monitor_tunnel.py
    monitor_tunnel("https://yourtunnel.pinggy.io")
```

---

## 🎯 Conclusion

### Recommendations Summary:

| Scenario | Recommended Tool | Why? |
|---------|----------------------|----------|
| **Quick test** | `localhost.run` | Zero installation, simplest |
| **Continuous development** | **Cloudflare Tunnel** | Stable, with analytics |
| **Detailed debugging** | **Pinggy** | Interactive terminal with inspection |
| **Full control** | **FRP** | Self-hosted, complete configuration |
| **Alternative to ngrok** | **Tunnelmole** | Familiar interface, easy migration |

### Next Steps:

1. **Start simple**: Test with `localhost.run` first
2. **Evolve as needed**: Migrate to Cloudflare when you need more features
3. **Consider self-hosting**: If you need full control, use FRP
4. **Always prioritize security**: Never expose sensitive services

### Checklist Before Sharing:
- [ ] Local server is working (`curl localhost:PORT`)
- [ ] Tunnel created successfully
- [ ] Public URL accessible
- [ ] Authentication configured (if needed)
- [ ] Sensitive data removed/hidden

---

**📞 Community Support**:  
Found a problem? Check the project's GitHub issues or ask on forums like Stack Overflow.

**🔄 Updates**:  
This guide is regularly updated. Check the last revision date and consult official repositories for the latest information.

**🤝 Contribute**:  
Found an error? Have a suggestion? Contribute to the project or open an issue!

---

*Last update: January 2026*  
*License: CC BY-SA 4.0 - Feel free to share and adapt, with attribution.*