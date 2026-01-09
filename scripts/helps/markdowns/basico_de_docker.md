# Docker - Guia Básico Rápido

## 🐳 Comandos Essenciais

### 1. Criar e Rodar um Container Rapidamente
```bash
# Cria e inicia um container interativamente
docker run -it --name meu-container ubuntu:latest bash
```
- `-it`: Modo interativo com terminal
- `--name`: Nome do container
- `ubuntu:latest`: Imagem base (pode usar `alpine`, `debian`, etc.)
- `bash`: Shell para entrar diretamente

### 2. Entrar em um Container Existente
```bash
# Se o container já estiver rodando
docker exec -it meu-container bash

# Se o container estiver parado, iniciar e entrar
docker start meu-container
docker exec -it meu-container bash
```

## 📦 Exemplo de Fluxo Completo

### Passo 1: Criar container e instalar pacotes
```bash
# Cria container com Ubuntu
docker run -it --name meu-container ubuntu:latest bash

# Dentro do container, instale o que quiser:
apt-get update
apt-get install python3 curl vim -y

# Execute seus programas
python3 --version
```

### Passo 2: Trabalhar dentro do container
```bash
# Para sair do container sem parar (background)
Ctrl+P seguido de Ctrl+Q

# Para reentrar
docker attach meu-container
```

### Passo 3: Remover completamente (PURGE)
```bash
# Parar o container
docker stop meu-container

# Remover container completamente
docker rm meu-container

# Para forçar remoção se estiver rodando
docker rm -f meu-container

# Limpar tudo: containers parados, imagens não usadas, cache
docker system prune -a --volumes
```

## 🚀 Atalhos Rápidos

### Criar, Usar e Destruir em um comando
```bash
# Container temporário - será destruído ao sair
docker run -it --rm ubuntu:latest bash
```
- `--rm`: Remove automaticamente ao sair

### Script de "Usar e Descarte"
```bash
# Cria, usa e remove tudo após uso
docker run -it --name temp-container --rm ubuntu:latest bash
# Trabalhe dentro...
# Ao sair com 'exit', o container é automaticamente removido
```

## 📝 Dicas Importantes

### Persistência de Dados
```bash
# Se quiser manter dados mesmo removendo container
docker run -it -v $(pwd)/dados:/app --name meu-container ubuntu:latest
```
- `-v`: Cria volume persistente

### Ver Containers
```bash
# Listar containers ativos
docker ps

# Listar todos (incluindo parados)
docker ps -a

# Ver informações específicas
docker inspect meu-container
```

### Limpeza Completa (PURGE TOTAL)
```bash
# Remover TUDO (containers, imagens, volumes, redes)
docker system prune -a --volumes --force

# Para remover apenas containers parados
docker container prune

# Para remover apenas imagens não usadas
docker image prune
```

## ⚠️ Avisos
1. Containers são **efêmeros** por padrão
2. Sem `--rm` ou `docker rm`, containers ficam no sistema
3. Instalações dentro do container são perdidas ao removê-lo
4. Use volumes para dados importantes

## 🎯 Resumo dos Seus Comandos Desejados
```bash
# "docker cria meu container"
docker run -it --name "meu-container" ubuntu bash

# "docker entrar no meu container"
docker exec -it "meu-container" bash

# "docker purge container"
docker rm -f "meu-container" && docker system prune -a --volumes
```

Pronto! Agora você pode criar, usar e remover containers rapidamente sem deixar rastros! 🐳

---

# Docker: Usuários e Privilégios

## 👤 Root vs Usuário Normal

Por padrão, Docker roda como **root** dentro do container, mas você pode e DEVE configurar usuários não-privilegiados para maior segurança.

### 1. Usando Usuário Não-Root na Criação

```bash
# Criar container com usuário específico
docker run -it --name meu-container --user 1000:1000 ubuntu bash

# Ou criar com usuário específico
docker run -it --name meu-container -u myuser ubuntu bash
```

### 2. Criar e Configurar Usuário Personalizado

**Dockerfile para criar usuário:**
```dockerfile
FROM ubuntu:latest

# Criar usuário e grupo
RUN groupadd -g 1000 appuser && \
    useradd -m -u 1000 -g appuser appuser

# Mudar para o usuário
USER appuser

WORKDIR /home/appuser

CMD ["bash"]
```

### 3. Criar Container com Usuário Personalizado (One-liner)

```bash
# Cria container, adiciona usuário, e já entra como ele
docker run -it --name meu-container ubuntu bash -c "
  useradd -m myuser && \
  echo 'myuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  su - myuser"
```

### 4. Método Mais Prático: Criar e Usar Direto

```bash
# 1. Cria o container
docker run -d --name meu-container ubuntu tail -f /dev/null

# 2. Cria usuário dentro
docker exec meu-container bash -c "
  useradd -m -s /bin/bash devuser && \
  echo 'devuser:password123' | chpasswd"

# 3. Entra como o usuário
docker exec -it --user devuser meu-container bash
```

## 🔐 Boas Práticas de Segurança

### Container Seguro com Usuário Não-Root
```bash
# Criação segura com usuário limitado
docker run -it \
  --name app-seguro \
  --user 1000:1000 \
  --read-only \
  --security-opt=no-new-privileges \
  ubuntu bash
```

### Volume com Permissões Corretas
```bash
# Criar diretório local com seu usuário
mkdir ~/meu-app
sudo chown $USER:$USER ~/meu-app

# Montar volume com seu UID/GID
docker run -it \
  --name meu-app \
  --user $(id -u):$(id -g) \
  -v ~/meu-app:/app \
  ubuntu bash
```

## 🚀 Script Completo "Cria-Usa-Purge" com Usuário

```bash
#!/bin/bash
# script-docker-user.sh

CONTAINER_NAME="meu-container"
IMAGE="ubuntu:latest"

echo "1. Criando container com usuário personalizado..."
docker run -d --name $CONTAINER_NAME $IMAGE tail -f /dev/null

echo "2. Criando usuário 'developer' dentro do container..."
docker exec $CONTAINER_NAME bash -c "
  apt-get update && apt-get install -y sudo && \
  useradd -m -s /bin/bash developer && \
  echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  mkdir -p /home/developer/project && \
  chown -R developer:developer /home/developer"

echo "3. Entrando no container como usuário 'developer'..."
docker exec -it --user developer $CONTAINER_NAME bash

echo "4. Ao sair, o container será mantido."
echo "   Para remover completamente: docker rm -f $CONTAINER_NAME"
```

## 📊 Comparação Root vs Usuário

### Com Root (padrão - INSECURO)
```bash
# ❌ Problemas:
# - Permissões totais
# - Arquivos criados como root fora do container
# - Risco de segurança

docker run -it ubuntu bash
# Dentro: whoami  # retorna "root"
```

### Com Usuário Limitado (RECOMENDADO)
```bash
# ✅ Vantagens:
# - Mais seguro
# - Permissões corretas nos volumes
# - Isolamento melhor

docker run -it --user 1000:1000 ubuntu bash
# Dentro: whoami  # retorna usuário com UID 1000
```

## 🎯 Comandos Rápidos Personalizados

### Para seu fluxo desejado:

```bash
# Alias para .bashrc ou .zshrc
alias docker-cria="docker run -it --name meu-container --user $(id -u):$(id -g) ubuntu bash"
alias docker-entra="docker exec -it --user $(id -u):$(id -g) meu-container bash"
alias docker-purge="docker rm -f meu-container && docker system prune -af --volumes"
```

### Uso:
```bash
# Cria container com SEU usuário
docker-cria

# Entra como SEU usuário
docker-entra

# Destrói tudo
docker-purge
```

## ⚠️ Problemas Comuns e Soluções

### Problema: Permissão negada em volumes
```bash
# Solução: Use seu UID/GID
docker run -it -v $(pwd):/app --user $(id -u):$(id -g) ubuntu bash
```

### Problema: Não consegue instalar pacotes
```bash
# Como usuário não-root, use sudo
docker run -it --user 1000:1000 ubuntu bash
# Dentro:
sudo apt-get update  # se configurado no Dockerfile
# OU entre como root temporariamente
docker exec -it --user root meu-container bash
```

### Problema: Usuário não existe no container
```bash
# Crie o usuário primeiro
docker exec meu-container adduser --disabled-password --gecos '' meuuser
```

## 📌 Resumo Final

**Para containers rápidos e seguros:**
```bash
# 1. Cria com seu usuário do host
docker run -it --name temp --user $(id -u):$(id -g) --rm ubuntu bash

# 2. Se precisar root temporariamente
docker exec -it --user root temp bash

# 3. Remove sem deixar rastros
exit  # container com --rm é automaticamente removido
```

**Regra de ouro:** 
- Use `--user $(id -u):$(id -g)` para desenvolvimento
- Use `--rm` para containers descartáveis
- Use Dockerfile com `USER` directive para produção

---

# Docker com Arch Linux 🐧🎯

**Sim, absolutamente!** Docker não está limitado ao Ubuntu. Você pode usar praticamente qualquer distribuição Linux, incluindo **Arch Linux** (e derivados como Manjaro).

## 🚀 Arch Linux no Docker

### 1. Imagem Oficial do Arch Linux
```bash
# Pull da imagem oficial do Arch
docker pull archlinux

# Criar container Arch básico
docker run -it --name meu-arch archlinux bash
```

### 2. Versões/Tags Disponíveis
```bash
# Listar tags disponíveis
docker search archlinux

# Tags comuns:
docker pull archlinux:latest          # Rolling release mais recente
docker pull archlinux:base            # Base mínima
docker pull archlinux:base-devel      # Com ferramentas de desenvolvimento
```

## 📦 Comparação: Arch vs Ubuntu no Docker

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

## 🎯 Criando Container Arch Linux Rápido

### Comando Único para Arch:
```bash
# Cria, entra, e remove ao sair
docker run -it --rm --name arch-container archlinux bash
```

### Arch com Usuário Personalizado:
```bash
docker run -it --rm \
  --name arch-dev \
  --user $(id -u):$(id -g) \
  archlinux bash
```

## 🔧 Instalação Rápida no Arch Docker

Dentro do container Arch:
```bash
# Atualizar sistema
pacman -Syu --noconfirm

# Instalar pacotes essenciais
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

# Instalar AUR helper (yay) - em container não é comum, mas possível
```

## 🐳 Outras Distribuições Disponíveis

### Debian/Família:
```bash
docker pull debian
docker pull kali-linux  # Kali Linux
docker pull parrotsec/parrot-core  # Parrot OS
```

### RHEL/Família:
```bash
docker pull centos:stream
docker pull fedora
docker pull rockylinux/rockylinux
docker pull oraclelinux
```

### Outras:
```bash
docker pull alpine  # Muito leve (~5MB)
docker pull opensuse/leap
docker pull gentoo/stage3
docker pull voidlinux/voidlinux
docker pull nixos/nix
```

## 🎭 Distribuições Específicas/Especializadas

### Para Segurança:
```bash
docker pull kalilinux/kali-rolling
docker pull parrotsec/parrot-core
docker pull blackarchlinux/blackarch
```

### Para Desktop (com X11):
```bash
# Arch com XFCE
docker pull jlesage/xfce-vnc

# Ubuntu com GNOME
docker pull dorowu/ubuntu-desktop-lxde-vnc
```

### Para Desenvolvimento:
```bash
docker pull mcr.microsoft.com/devcontainers/base:ubuntu  # Dev Containers
docker pull archlinux:base-devel
```

## 📝 Dockerfile Personalizado Arch Linux

**Dockerfile:**
```dockerfile
FROM archlinux:latest

# Atualizar e instalar pacotes
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

# Criar usuário não-root
RUN useradd -m -G wheel -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER developer
WORKDIR /home/developer

CMD ["/bin/bash"]
```

**Build e uso:**
```bash
# Construir imagem
docker build -t meu-arch-custom .

# Usar
docker run -it --rm meu-arch-custom
```

## 🚀 Comandos Rápidos Arch Docker

### Script "arch-docker.sh":
```bash
#!/bin/bash

# Criar container Arch com ferramentas de dev
docker run -it --rm \
  --name arch-dev \
  --hostname arch-docker \
  -v "$(pwd)":/home/developer/project \
  --user $(id -u):$(id -g) \
  archlinux bash -c "
    # Dentro do container
    echo 'Atualizando Arch Linux...'
    pacman -Syu --noconfirm 2>/dev/null || true
    
    echo 'Instalando pacotes essenciais...'
    pacman -S --noconfirm \
      git vim neovim base-devel \
      python python-pip nodejs npm \
      2>/dev/null || true
    
    echo 'Configurando ambiente...'
    export PS1='[\u@arch-docker \W]\$ '
    
    cd /home/developer/project
    exec bash
  "
```

### Atalhos para seu .bashrc:
```bash
# Arch Linux
alias arch-docker='docker run -it --rm archlinux bash'
alias arch-dev='docker run -it --rm -v $(pwd):/app archlinux bash'

# Alpine (muito leve)
alias alpine-docker='docker run -it --rm alpine sh'

# Debian
alias debian-docker='docker run -it --rm debian bash'

# Fedora
alias fedora-docker='docker run -it --rm fedora bash'
```

## 🔄 Migrando de Ubuntu para Arch no Docker

**Se você está acostumado com Ubuntu:**

| Ubuntu | Arch Linux Equivalente |
|--------|-----------------------|
| `apt update` | `pacman -Sy` |
| `apt install` | `pacman -S` |
| `apt remove` | `pacman -Rs` |
| `apt search` | `pacman -Ss` |
| `apt upgrade` | `pacman -Syu` |
| `apt autoremove` | `pacman -Rns $(pacman -Qtdq)` |

**Exemplo prático:**
```bash
# No Ubuntu:
docker run -it ubuntu bash
apt update && apt install python3

# No Arch:
docker run -it archlinux bash
pacman -Sy && pacman -S python
```

## ⚡ Distribuições Leves (Alternativas)

### Alpine Linux (Super leve - ~5MB)
```bash
docker pull alpine
docker run -it --rm alpine sh
# Use apk ao invés de apt
apk add python3 nodejs git
```

### BusyBox (Mini - ~1MB)
```bash
docker pull busybox
docker run -it --rm busybox sh
```

## 🎯 Conclusão: Qual usar?

- **Arch Linux**: Rolling release, sempre atualizado, pacotes recentes
- **Ubuntu**: Estável, ampla compatibilidade, documentação extensa
- **Alpine**: Leve, segura, ótima para produção
- **Debian**: Estabilidade extrema, conservador
- **Fedora**: Cutting-edge, foco em novas tecnologias

## 📌 Exemplo Final Arch + Dev Tools

```bash
# Container Arch completo para desenvolvimento
docker run -it --rm \
  --name full-arch \
  --hostname arch-dev \
  -v ~/projects:/projects \
  -v ~/.ssh:/home/developer/.ssh \
  -v ~/.gitconfig:/home/developer/.gitconfig \
  -e TERM=xterm-256color \
  archlinux bash -c "
    # Configurar Arch
    pacman -Syu --noconfirm
    pacman -S --noconfirm \
      git neovim tmux zsh \
      python python-pip python-virtualenv \
      nodejs npm yarn \
      go rustup \
      docker docker-compose
    
    # Criar usuário
    useradd -m -s /bin/zsh developer
    su - developer
  "
```

**Resposta curta:** 
```bash
# Sim! Use Arch no Docker:
docker run -it --rm archlinux bash

# Ou Alpine para algo super leve:
docker run -it --rm alpine sh
```

Escolha a distribuição que melhor se adapta ao seu fluxo de trabalho! 🐧🐳

---

# Docker - Arquivos de Configuração e Redes

## ⚙️ Arquivos de Configuração Comuns

### 1. Dockerfile - Definição da Imagem
```dockerfile
FROM ubuntu:22.04

# Metadados
LABEL maintainer="seu@email.com"
LABEL version="1.0"
LABEL description="Imagem personalizada"

# Variáveis de ambiente
ENV APP_HOME=/app \
    NODE_ENV=production \
    PYTHONUNBUFFERED=1

# Diretório de trabalho
WORKDIR $APP_HOME

# Copiar arquivos
COPY package.json .
COPY requirements.txt .
COPY src/ ./src/

# Instalar dependências
RUN apt-get update && \
    apt-get install -y python3-pip nodejs && \
    pip install -r requirements.txt

# Expor portas
EXPOSE 3000
EXPOSE 8000

# Comando de inicialização
CMD ["python3", "app.py"]
```

### 2. docker-compose.yml - Orquestração
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    container_name: meu-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./html:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf
    networks:
      - rede-app
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
      - rede-app

  db:
    image: postgres:15
    container_name: postgres-db
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: senha123
      POSTGRES_DB: mydatabase
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - rede-app

  redis:
    image: redis:alpine
    container_name: cache-redis
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - rede-app

networks:
  rede-app:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
```

### 3. .dockerignore - Excluir Arquivos
```
# Arquivos para ignorar no build
.git
.gitignore
README.md
*.log
*.tmp
.env

# Diretórios
node_modules/
__pycache__/
.venv/
dist/
build/

# Arquivos de IDE
.vscode/
.idea/
*.swp
```

### 4. Configuração de Rede Personalizada
```bash
# Criar rede bridge personalizada
docker network create --driver bridge minha-rede --subnet 172.20.0.0/16

# Listar redes
docker network ls

# Inspecionar rede
docker network inspect minha-rede

# Conectar container a rede
docker network connect minha-rede meu-container

# Desconectar
docker network disconnect minha-rede meu-container
```

## 🌐 Tipos de Rede no Docker

### Bridge (Padrão)
```bash
# Criar container na rede bridge padrão
docker run -d --name web --network bridge nginx

# Criar rede bridge personalizada
docker network create --driver bridge rede-isolada
```

### Host (Usa rede do host)
```bash
# Container compartilha rede com host
docker run -d --name web --network host nginx
# Cuidado: portas do container conflitam com host
```

### None (Sem rede)
```bash
# Container totalmente isolado
docker run -it --name isolated --network none alpine sh
```

### Overlay (Para Docker Swarm)
```bash
# Redes multi-host (clusters)
docker network create --driver overlay rede-cluster
```

## 🔗 Comunicação entre Containers

### Método 1: Links (Legado)
```bash
# Criar containers linkados
docker run -d --name db postgres
docker run -d --name app --link db:database minha-app
# Dentro do container "app": ping database
```

### Método 2: Rede Compartilhada (Recomendado)
```bash
# 1. Criar rede
docker network create app-network

# 2. Conectar containers
docker run -d --name db --network app-network postgres
docker run -d --name app --network app-network minha-app

# 3. Comunicação por nome
# De "app" para "db": ping db
# URL de conexão: db:5432
```

### Método 3: DNS Automático
```bash
# Docker tem DNS interno
docker run -d --name api --network minha-rede python-app

# Outro container pode acessar por nome
docker exec cliente ping api  # Resolve para IP do container
```

## 🛡️ Segurança de Redes

### Container Isolado
```bash
docker run -it \
  --network none \
  --cap-drop=ALL \
  --read-only \
  alpine sh
```

### Rede com Restrições
```bash
# Criar rede com firewall
docker network create \
  --driver bridge \
  --opt com.docker.network.bridge.enable_icc=false \
  rede-segura
```

## 📊 Exemplo Prático: Ambiente Web Completo

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

  # Admin (só acessa database)
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

## 🚀 Comandos Avançados de Rede

### Portas Dinâmicas
```bash
# Mapear porta automática
docker run -d -P nginx  # -P mapeia todas as portas EXPOSE
docker port <container>  # Ver portas mapeadas
```

### Portas Específicas
```bash
# Mapeamento direto
docker run -d -p 8080:80 nginx  # host:container

# Mapear para IP específico
docker run -d -p 127.0.0.1:8080:80 nginx

# Múltiplas portas
docker run -d -p 80:80 -p 443:443 nginx
```

### Troubleshooting de Rede
```bash
# Ver conexões do container
docker exec meu-container netstat -tulpn

# Testar conectividade
docker exec meu-container ping google.com

# Ver DNS resolvido
docker exec meu-container cat /etc/resolv.conf

# Logs de rede
docker logs meu-container
```

## 🎯 Script de Rede Completo

```bash
#!/bin/bash
# rede-docker.sh

# Criar rede
NETWORK="meu-app-network"
SUBNET="172.22.0.0/16"
GATEWAY="172.22.0.1"

echo "Criando rede $NETWORK..."
docker network create \
  --driver bridge \
  --subnet $SUBNET \
  --gateway $GATEWAY \
  $NETWORK

# Criar containers conectados
echo "Criando containers..."

# Banco de dados
docker run -d \
  --name db \
  --network $NETWORK \
  --ip 172.22.0.10 \
  -e POSTGRES_PASSWORD=senha123 \
  postgres:15

# Aplicação
docker run -d \
  --name app \
  --network $NETWORK \
  --ip 172.22.0.20 \
  -p 8080:80 \
  --link db:database \
  minha-app:latest

# Testar
echo "Testando conectividade..."
docker exec app ping -c 3 db

echo "Rede configurada!"
echo "Containers:"
docker network inspect $NETWORK --format='{{range .Containers}}{{.Name}} {{.IPv4Address}}{{println}}{{end}}'
```

## 📌 Dicas de Configuração

### Variáveis de Ambiente
```bash
# Arquivo .env
DB_HOST=database
DB_PORT=5432
REDIS_URL=redis://cache:6379

# Usar no docker-compose
docker-compose --env-file .env up

# Ou no run
docker run -d --env-file .env minha-app
```

### Health Checks
```dockerfile
# No Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1
```

```yaml
# No docker-compose.yml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 🔄 Backup e Restauração de Configurações

### Exportar Configuração
```bash
# Salvar configuração de container
docker inspect meu-container > config-meu-container.json

# Exportar rede
docker network inspect minha-rede > rede-config.json
```

### Importar/Recriar
```bash
# Recriar rede a partir de configuração
docker network create minha-rede-copy --config rede-config.json

# Criar container com configuração similar
docker run --name novo-container \
  $(cat config-meu-container.json | jq -r '.[0].Config.Env[] | select(.!=null) | "--env " + .') \
  mesma-imagem
```

## 🎮 Exemplo Interativo: Chat Multi-container

```bash
# Criar rede para chat
docker network create chat-net

# Servidor de chat
docker run -d --name chat-server --network chat-net -p 5000:5000 chat-server:latest

# Cliente 1
docker run -it --name user1 --network chat-net chat-client --server chat-server:5000 --user Alice

# Cliente 2
docker run -it --name user2 --network chat-net chat-client --server chat-server:5000 --user Bob

# Monitor
docker run -it --name monitor --network chat-net chat-monitor --server chat-server:5000
```

## ⚡ Performance de Rede

### Otimizações
```bash
# Usar network_mode: host para máxima performance
docker run -d --network host nginx

# Usar rede bridge personalizada
docker network create --opt com.docker.network.bridge.name=br0 minha-rede

# Container com limites de rede
docker run -d \
  --network minha-rede \
  --sysctl net.core.somaxconn=1024 \
  --ulimit nofile=65536:65536 \
  minha-app
```

## 📊 Monitoramento de Rede

```bash
# Estatísticas de rede do container
docker stats meu-container

# Ver uso de rede
docker exec meu-container ifconfig eth0

# Monitorar conexões
watch -n 1 'docker exec meu-container netstat -an | grep ESTABLISHED'

# Logs de conexão
docker logs --tail 100 -f meu-container | grep -E "(CONNECT|DISCONNECT)"
```
