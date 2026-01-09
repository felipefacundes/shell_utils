# Docker - Basic Quick Guide

## 🐳 Essential Commands

### 1. Create and Run a Container Quickly
```bash
# Creates and starts a container interactively
docker run -it --name my-container ubuntu:latest bash
```
- `-it`: Interactive mode with terminal
- `--name`: Container name
- `ubuntu:latest`: Base image (can use `alpine`, `debian`, etc.)
- `bash`: Shell to enter directly

### 2. Enter an Existing Container
```bash
# If the container is already running
docker exec -it my-container bash

# If the container is stopped, start it and enter
docker start my-container
docker exec -it my-container bash
```

## 📦 Complete Workflow Example

### Step 1: Create container and install packages
```bash
# Create container with Ubuntu
docker run -it --name my-container ubuntu:latest bash

# Inside the container, install what you want:
apt-get update
apt-get install python3 curl vim -y

# Run your programs
python3 --version
```

### Step 2: Work inside the container
```bash
# To exit the container without stopping it (background)
Ctrl+P followed by Ctrl+Q

# To re-enter
docker attach my-container
```

### Step 3: Remove completely (PURGE)
```bash
# Stop the container
docker stop my-container

# Remove container completely
docker rm my-container

# To force removal if running
docker rm -f my-container

# Clean everything: stopped containers, unused images, cache
docker system prune -a --volumes
```

## 🚀 Quick Shortcuts

### Create, Use and Destroy in one command
```bash
# Temporary container - will be destroyed upon exit
docker run -it --rm ubuntu:latest bash
```
- `--rm`: Removes automatically upon exit

### "Use and Discard" Script
```bash
# Creates, uses and removes everything after use
docker run -it --name temp-container --rm ubuntu:latest bash
# Work inside...
# When exiting with 'exit', the container is automatically removed
```

## 📝 Important Tips

### Data Persistence
```bash
# If you want to keep data even when removing the container
docker run -it -v $(pwd)/data:/app --name my-container ubuntu:latest
```
- `-v`: Creates persistent volume

### View Containers
```bash
# List active containers
docker ps

# List all (including stopped ones)
docker ps -a

# View specific information
docker inspect my-container
```

### Complete Cleanup (TOTAL PURGE)
```bash
# Remove EVERYTHING (containers, images, volumes, networks)
docker system prune -a --volumes --force

# To remove only stopped containers
docker container prune

# To remove only unused images
docker image prune
```

## ⚠️ Warnings
1. Containers are **ephemeral** by default
2. Without `--rm` or `docker rm`, containers remain in the system
3. Installations inside the container are lost when removing it
4. Use volumes for important data

## 🎯 Summary of Your Desired Commands
```bash
# "docker creates my container"
docker run -it --name "my-container" ubuntu bash

# "docker enter my container"
docker exec -it "my-container" bash

# "docker purge container"
docker rm -f "my-container" && docker system prune -a --volumes
```

Ready! Now you can create, use and remove containers quickly without leaving traces! 🐳

---

# Docker: Users and Privileges

## 👤 Root vs Normal User

By default, Docker runs as **root** inside the container, but you can and SHOULD configure non-privileged users for better security.

### 1. Using Non-Root User at Creation

```bash
# Create container with specific user
docker run -it --name my-container --user 1000:1000 ubuntu bash

# Or create with specific user
docker run -it --name my-container -u myuser ubuntu bash
```

### 2. Create and Configure Custom User

**Dockerfile to create user:**
```dockerfile
FROM ubuntu:latest

# Create user and group
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g appuser appuser

# Switch to user
USER appuser

WORKDIR /home/appuser

CMD ["bash"]
```

### 3. Create Container with Custom User (One-liner)

```bash
# Creates container, adds user, and already enters as that user
docker run -it --name my-container ubuntu bash -c "
  useradd -m myuser && \
  echo 'myuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  su - myuser"
```

### 4. More Practical Method: Create and Use Directly

```bash
# 1. Create the container
docker run -d --name my-container ubuntu tail -f /dev/null

# 2. Create user inside
docker exec my-container bash -c "
  useradd -m -s /bin/bash devuser && \
  echo 'devuser:password123' | chpasswd"

# 3. Enter as the user
docker exec -it --user devuser my-container bash
```

## 🔐 Security Best Practices

### Secure Container with Non-Root User
```bash
# Secure creation with limited user
docker run -it \
  --name secure-app \
  --user 1000:1000 \
  --read-only \
  --security-opt=no-new-privileges \
  ubuntu bash
```

### Volume with Correct Permissions
```bash
# Create local directory with your user
mkdir ~/my-app
sudo chown $USER:$USER ~/my-app

# Mount volume with your UID/GID
docker run -it \
  --name my-app \
  --user $(id -u):$(id -g) \
  -v ~/my-app:/app \
  ubuntu bash
```

## 🚀 Complete "Create-Use-Purge" Script with User

```bash
#!/bin/bash
# script-docker-user.sh

CONTAINER_NAME="my-container"
IMAGE="ubuntu:latest"

echo "1. Creating container with custom user..."
docker run -d --name $CONTAINER_NAME $IMAGE tail -f /dev/null

echo "2. Creating 'developer' user inside the container..."
docker exec $CONTAINER_NAME bash -c "
  apt-get update && apt-get install -y sudo && \
  useradd -m -s /bin/bash developer && \
  echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  mkdir -p /home/developer/project && \
  chown -R developer:developer /home/developer"

echo "3. Entering container as 'developer' user..."
docker exec -it --user developer $CONTAINER_NAME bash

echo "4. Upon exit, the container will be kept."
echo "   To remove completely: docker rm -f $CONTAINER_NAME"
```

## 📊 Root vs User Comparison

### With Root (default - INSECURE)
```bash
# ❌ Problems:
# - Full permissions
# - Files created as root outside the container
# - Security risk

docker run -it ubuntu bash
# Inside: whoami  # returns "root"
```

### With Limited User (RECOMMENDED)
```bash
# ✅ Advantages:
# - More secure
# - Correct permissions on volumes
# - Better isolation

docker run -it --user 1000:1000 ubuntu bash
# Inside: whoami  # returns user with UID 1000
```

## 🎯 Quick Personalized Commands

### For your desired workflow:

```bash
# Aliases for .bashrc or .zshrc
alias docker-create="docker run -it --name my-container --user $(id -u):$(id -g) ubuntu bash"
alias docker-enter="docker exec -it --user $(id -u):$(id -g) my-container bash"
alias docker-purge="docker rm -f my-container && docker system prune -af --volumes"
```

### Usage:
```bash
# Create container with YOUR user
docker-create

# Enter as YOUR user
docker-enter

# Destroy everything
docker-purge
```

## ⚠️ Common Problems and Solutions

### Problem: Permission denied on volumes
```bash
# Solution: Use your UID/GID
docker run -it -v $(pwd):/app --user $(id -u):$(id -g) ubuntu bash
```

### Problem: Cannot install packages
```bash
# As non-root user, use sudo
docker run -it --user 1000:1000 ubuntu bash
# Inside:
sudo apt-get update  # if configured in Dockerfile
# OR enter as root temporarily
docker exec -it --user root my-container bash
```

### Problem: User doesn't exist in container
```bash
# Create the user first
docker exec my-container adduser --disabled-password --gecos '' myuser
```

## 📌 Final Summary

**For quick and secure containers:**
```bash
# 1. Create with your host user
docker run -it --name temp --user $(id -u):$(id -g) --rm ubuntu bash

# 2. If you need root temporarily
docker exec -it --user root temp bash

# 3. Remove without leaving traces
exit  # container with --rm is automatically removed
```

**Golden rule:** 
- Use `--user $(id -u):$(id -g)` for development
- Use `--rm` for disposable containers
- Use Dockerfile with `USER` directive for production

---

# Docker with Arch Linux 🐧🎯

**Yes, absolutely!** Docker is not limited to Ubuntu. You can use practically any Linux distribution, including **Arch Linux** (and derivatives like Manjaro).

## 🚀 Arch Linux in Docker

### 1. Official Arch Linux Image
```bash
# Pull official Arch image
docker pull archlinux

# Create basic Arch container
docker run -it --name my-arch archlinux bash
```

### 2. Available Versions/Tags
```bash
# List available tags
docker search archlinux

# Common tags:
docker pull archlinux:latest          # Most recent rolling release
docker pull archlinux:base            # Minimal base
docker pull archlinux:base-devel      # With development tools
```

## 📦 Comparison: Arch vs Ubuntu in Docker

### Ubuntu (APT-based)
```bash
docker run -it ubuntu bash
apt-get update
apt-get install package
```

### Arch (Pacman-based)
```bash
docker run -it archlinux bash
pacman -Sy
pacman -S package
```

## 🎯 Creating Quick Arch Linux Container

### Single Command for Arch:
```bash
# Creates, enters, and removes upon exit
docker run -it --rm --name arch-container archlinux bash
```

### Arch with Custom User:
```bash
docker run -it --rm \
  --name arch-dev \
  --user $(id -u):$(id -g) \
  archlinux bash
```

## 🔧 Quick Installation in Arch Docker

Inside the Arch container:
```bash
# Update system
pacman -Syu --noconfirm

# Install essential packages
pacman -S --noconfirm \
  base-devel \
  git \
  vim \
  neovim \
  python \
  nodejs \
  npm \
  go \
  rust \
  docker \
  podman

# Install AUR helper (yay) - not common in containers, but possible
```

## 🐳 Other Available Distributions

### Debian/Family:
```bash
docker pull debian
docker pull kali-linux  # Kali Linux
docker pull parrotsec/parrot-core  # Parrot OS
```

### RHEL/Family:
```bash
docker pull centos:stream
docker pull fedora
docker pull rockylinux/rockylinux
docker pull oraclelinux
```

### Others:
```bash
docker pull alpine  # Very light (~5MB)
docker pull opensuse/leap
docker pull gentoo/stage3
docker pull voidlinux/voidlinux
docker pull nixos/nix
```

## 🎭 Specific/Specialized Distributions

### For Security:
```bash
docker pull kalilinux/kali-rolling
docker pull parrotsec/parrot-core
docker pull blackarchlinux/blackarch
```

### For Desktop (with X11):
```bash
# Arch with XFCE
docker pull jlesage/xfce-vnc

# Ubuntu with GNOME
docker pull dorowu/ubuntu-desktop-lxde-vnc
```

### For Development:
```bash
docker pull mcr.microsoft.com/devcontainers/base:ubuntu  # Dev Containers
docker pull archlinux:base-devel
```

## 📝 Custom Arch Linux Dockerfile

**Dockerfile:**
```dockerfile
FROM archlinux:latest

# Update and install packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      base-devel \
      git \
      vim \
      python \
      python-pip \
      nodejs \
      npm \
      go \
      rustup \
      docker \
      man-db \
      man-pages

# Create non-root user
RUN useradd -m -G wheel -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER developer
WORKDIR /home/developer

CMD ["/bin/bash"]
```

**Build and use:**
```bash
# Build image
docker build -t my-arch-custom .

# Use
docker run -it --rm my-arch-custom
```

## 🚀 Quick Arch Docker Commands

### Script "arch-docker.sh":
```bash
#!/bin/bash

# Create Arch container with dev tools
docker run -it --rm \
  --name arch-dev \
  --hostname arch-docker \
  -v "$(pwd)":/home/developer/project \
  --user $(id -u):$(id -g) \
  archlinux bash -c "
    # Inside the container
    echo 'Updating Arch Linux...'
    pacman -Syu --noconfirm 2>/dev/null || true
    
    echo 'Installing essential packages...'
    pacman -S --noconfirm \
      git vim neovim base-devel \
      python python-pip nodejs npm \
      2>/dev/null || true
    
    echo 'Setting up environment...'
    export PS1='[\u@arch-docker \W]\$ '
    
    cd /home/developer/project
    exec bash
  "
```

### Shortcuts for your .bashrc:
```bash
# Arch Linux
alias arch-docker='docker run -it --rm archlinux bash'
alias arch-dev='docker run -it --rm -v $(pwd):/app archlinux bash'

# Alpine (very light)
alias alpine-docker='docker run -it --rm alpine sh'

# Debian
alias debian-docker='docker run -it --rm debian bash'

# Fedora
alias fedora-docker='docker run -it --rm fedora bash'
```

## 🔄 Migrating from Ubuntu to Arch in Docker

**If you're used to Ubuntu:**

| Ubuntu | Arch Linux Equivalent |
|--------|-----------------------|
| `apt update` | `pacman -Sy` |
| `apt install` | `pacman -S` |
| `apt remove` | `pacman -Rs` |
| `apt search` | `pacman -Ss` |
| `apt upgrade` | `pacman -Syu` |
| `apt autoremove` | `pacman -Rns $(pacman -Qtdq)` |

**Practical example:**
```bash
# In Ubuntu:
docker run -it ubuntu bash
apt update && apt install python3

# In Arch:
docker run -it archlinux bash
pacman -Sy && pacman -S python
```

## ⚡ Lightweight Distributions (Alternatives)

### Alpine Linux (Super light - ~5MB)
```bash
docker pull alpine
docker run -it --rm alpine sh
# Use apk instead of apt
apk add python3 nodejs git
```

### BusyBox (Mini - ~1MB)
```bash
docker pull busybox
docker run -it --rm busybox sh
```

## 🎯 Conclusion: Which to use?

- **Arch Linux**: Rolling release, always updated, recent packages
- **Ubuntu**: Stable, wide compatibility, extensive documentation
- **Alpine**: Light, secure, great for production
- **Debian**: Extreme stability, conservative
- **Fedora**: Cutting-edge, focus on new technologies

## 📌 Final Example Arch + Dev Tools

```bash
# Complete Arch container for development
docker run -it --rm \
  --name full-arch \
  --hostname arch-dev \
  -v ~/projects:/projects \
  -v ~/.ssh:/home/developer/.ssh \
  -v ~/.gitconfig:/home/developer/.gitconfig \
  -e TERM=xterm-256color \
  archlinux bash -c "
    # Configure Arch
    pacman -Syu --noconfirm
    pacman -S --noconfirm \
      git neovim tmux zsh \
      python python-pip python-virtualenv \
      nodejs npm yarn \
      go rustup \
      docker docker-compose
    
    # Create user
    useradd -m -s /bin/zsh developer
    su - developer
  "
```

**Short answer:** 
```bash
# Yes! Use Arch in Docker:
docker run -it --rm archlinux bash

# Or Alpine for something super light:
docker run -it --rm alpine sh
```

Choose the distribution that best fits your workflow! 🐧🐳

---

# Docker - Configuration Files and Networks

## ⚙️ Common Configuration Files

### 1. Dockerfile - Image Definition
```dockerfile
FROM ubuntu:22.04

# Metadata
LABEL maintainer="your@email.com"
LABEL version="1.0"
LABEL description="Custom image"

# Environment variables
ENV APP_HOME=/app \
    NODE_ENV=production \
    PYTHONUNBUFFERED=1

# Working directory
WORKDIR $APP_HOME

# Copy files
COPY package.json .
COPY requirements.txt .
COPY src/ ./src/

# Install dependencies
RUN apt-get update && \
    apt-get install -y python3-pip nodejs && \
    pip install -r requirements.txt

# Expose ports
EXPOSE 3000
EXPOSE 8000

# Startup command
CMD ["python3", "app.py"]
```

### 2. docker-compose.yml - Orchestration
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    container_name: my-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf
    networks:
      - app-network
    restart: unless-stopped

  app:
    build: .
    container_name: backend-app
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    networks:
      - app-network

  db:
    image: postgres:15
    container_name: postgres-db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password123
      POSTGRES_DB: mydatabase
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:alpine
    container_name: cache-redis
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
```

### 3. .dockerignore - Exclude Files
```
# Files to ignore in build
.git
.gitignore
README.md
*.log
*.tmp
.env

# Directories
node_modules/
__pycache__/
.venv/
dist/
build/

# IDE files
.vscode/
.idea/
*.swp
```

### 4. Custom Network Configuration
```bash
# Create custom bridge network
docker network create --driver bridge my-network --subnet 172.20.0.0/16

# List networks
docker network ls

# Inspect network
docker network inspect my-network

# Connect container to network
docker network connect my-network my-container

# Disconnect
docker network disconnect my-network my-container
```

## 🌐 Network Types in Docker

### Bridge (Default)
```bash
# Create container in default bridge network
docker run -d --name web --network bridge nginx

# Create custom bridge network
docker network create --driver bridge isolated-network
```

### Host (Uses host network)
```bash
# Container shares network with host
docker run -d --name web --network host nginx
# Warning: container ports conflict with host
```

### None (No network)
```bash
# Completely isolated container
docker run -it --name isolated --network none alpine sh
```

### Overlay (For Docker Swarm)
```bash
# Multi-host networks (clusters)
docker network create --driver overlay cluster-network
```

## 🔗 Communication Between Containers

### Method 1: Links (Legacy)
```bash
# Create linked containers
docker run -d --name db postgres
docker run -d --name app --link db:database my-app
# Inside "app" container: ping database
```

### Method 2: Shared Network (Recommended)
```bash
# 1. Create network
docker network create app-network

# 2. Connect containers
docker run -d --name db --network app-network postgres
docker run -d --name app --network app-network my-app

# 3. Communication by name
# From "app" to "db": ping db
# Connection URL: db:5432
```

### Method 3: Automatic DNS
```bash
# Docker has internal DNS
docker run -d --name api --network my-network python-app

# Another container can access by name
docker exec client ping api  # Resolves to container IP
```

## 🛡️ Network Security

### Isolated Container
```bash
docker run -it \
  --network none \
  --cap-drop=ALL \
  --read-only \
  alpine sh
```

### Network with Restrictions
```bash
# Create network with firewall
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.enable_icc=false \
  secure-network
```

## 📊 Practical Example: Complete Web Environment

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  # Frontend
  frontend:
    build: ./frontend
    ports:
      - "8080:80"
    networks:
      - app-network
    depends_on:
      - backend

  # Backend
  backend:
    build: ./backend
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=database
      - REDIS_HOST=cache
    networks:
      - app-network
    depends_on:
      - database
      - cache

  # Database
  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data
    networks:
      - app-network
      - admin-network

  # Cache
  cache:
    image: redis:alpine
    networks:
      - app-network

  # Admin (only accesses database)
  adminer:
    image: adminer
    ports:
      - "8081:8080"
    networks:
      - admin-network

networks:
  app-network:
    driver: bridge
  admin-network:
    driver: bridge

volumes:
  pgdata:
```

## 🚀 Advanced Network Commands

### Dynamic Ports
```bash
# Map automatic port
docker run -d -P nginx  # -P maps all EXPOSE ports
docker port <container>  # View mapped ports
```

### Specific Ports
```bash
# Direct mapping
docker run -d -p 8080:80 nginx  # host:container

# Map to specific IP
docker run -d -p 127.0.0.1:8080:80 nginx

# Multiple ports
docker run -d -p 80:80 -p 443:443 nginx
```

### Network Troubleshooting
```bash
# View container connections
docker exec my-container netstat -tulpn

# Test connectivity
docker exec my-container ping google.com

# View resolved DNS
docker exec my-container cat /etc/resolv.conf

# Network logs
docker logs my-container
```

## 🎯 Complete Network Script

```bash
#!/bin/bash
# network-docker.sh

# Create network
NETWORK="my-app-network"
SUBNET="172.22.0.0/16"
GATEWAY="172.22.0.1"

echo "Creating network $NETWORK..."
docker network create \
  --driver bridge \
  --subnet $SUBNET \
  --gateway $GATEWAY \
  $NETWORK

# Create connected containers
echo "Creating containers..."

# Database
docker run -d \
  --name db \
  --network $NETWORK \
  --ip 172.22.0.10 \
  -e POSTGRES_PASSWORD=password123 \
  postgres:15

# Application
docker run -d \
  --name app \
  --network $NETWORK \
  --ip 172.22.0.20 \
  -p 8080:80 \
  --link db:database \
  my-app:latest

# Test
echo "Testing connectivity..."
docker exec app ping -c 3 db

echo "Network configured!"
echo "Containers:"
docker network inspect $NETWORK --format='{{range .Containers}}{{.Name}} {{.IPv4Address}}{{println}}{{end}}'
```

## 📌 Configuration Tips

### Environment Variables
```bash
# .env file
DB_HOST=database
DB_PORT=5432
REDIS_URL=redis://cache:6379

# Use in docker-compose
docker-compose --env-file .env up

# Or in run
docker run -d --env-file .env my-app
```

### Health Checks
```dockerfile
# In Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
```

```yaml
# In docker-compose.yml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 🔄 Backup and Restore of Configurations

### Export Configuration
```bash
# Save container configuration
docker inspect my-container > config-my-container.json

# Export network
docker network inspect my-network > network-config.json
```

### Import/Recreate
```bash
# Recreate network from configuration
docker network create my-network-copy --config network-config.json

# Create container with similar configuration
docker run --name new-container \
  $(cat config-my-container.json | jq -r '.[0].Config.Env[] | select(.!=null) | "--env " + .') \
  same-image
```

## 🎮 Interactive Example: Multi-container Chat

```bash
# Create network for chat
docker network create chat-net

# Chat server
docker run -d --name chat-server --network chat-net -p 5000:5000 chat-server:latest

# Client 1
docker run -it --name user1 --network chat-net chat-client --server chat-server:5000 --user Alice

# Client 2
docker run -it --name user2 --network chat-net chat-client --server chat-server:5000 --user Bob

# Monitor
docker run -it --name monitor --network chat-net chat-monitor --server chat-server:5000
```

## ⚡ Network Performance

### Optimizations
```bash
# Use network_mode: host for maximum performance
docker run -d --network host nginx

# Use custom bridge network
docker network create --opt com.docker.network.bridge.name=br0 my-network

# Container with network limits
docker run -d \
  --network my-network \
  --sysctl net.core.somaxconn=1024 \
  --ulimit nofile=65536:65536 \
  my-app
```

## 📊 Network Monitoring

```bash
# Container network statistics
docker stats my-container

# View network usage
docker exec my-container ifconfig eth0

# Monitor connections
watch -n 1 'docker exec my-container netstat -an | grep ESTABLISHED'

# Connection logs
docker logs --tail 100 -f my-container | grep -E "(CONNECT|DISCONNECT)"
```