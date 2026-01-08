# Guia Completo: Expondo Serviços Locais com Túneis (Alternativas Gratuitas ao Ngrok)

## 📋 Índice
- [Visão Geral](#visão-geral)
- [Tabela Comparativa de Ferramentas](#-tabela-comparativa-de-ferramentas)
- [Guia de Escolha](#-guia-de-escolha-da-ferramenta-ideal)
- [Preparação do Ambiente](#-preparação-do-ambiente)
- [Tutoriais Práticos](#-tutoriais-práticos)
- [Casos de Uso Comuns](#-casos-de-uso-comuns)
- [Boas Práticas e Segurança](#-boas-práticas-e-segurança)
- [FAQ](#-perguntas-frequentes)
- [Recursos Adicionais](#-recursos-adicionais)

## Visão Geral

Este guia reúne ferramentas gratuitas e open-source para expor serviços locais na internet. Essas soluções são ideais para desenvolvedores que precisam testar webhooks, demonstrar projetos, acessar servidores domésticos ou compartilhar APIs em desenvolvimento.

## 🛠️ Tabela Comparativa de Ferramentas

| Nome | Preço (Tier Gratuito) | Instalação | Principal Vantagem | Protocolos Suportados | Requer Cadastro | Destaques |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Cloudflare Tunnel** | Gratuito (50 usuários) | Binário `cloudflared` | **Segurança e performance** com rede global | HTTP/HTTPS, TCP, UDP | Sim | Proteção DDoS, analytics, dashboard web |
| **localhost.run** | 100% gratuito | SSH puro | **Zero instalação** na máquina cliente | HTTP/HTTPS | Não | SSH direto, subdomínio estável |
| **Pinggy** | Gratuito (testes) | SSH com flags | **Terminal interativo** com debug | HTTP/HTTPS, TCP | Não para teste | Inspeção de tráfego em tempo real |
| **PageKite** | Gratuito (limite dados) | Script Python | **Open-source completo** | HTTP/HTTPS, TCP | Sim para features avançadas | Auto-hospedagem possível, Python-based |
| **Zrok** | Gratuito (self-hosted) | Binário GitHub | **Arquitetura zero-trust** | HTTP/HTTPS, TCP | Sim | Foco em segurança, controle total |
| **bore** | 100% open-source | Cargo/Rust | **Extremamente leve** | TCP tunneling | Não | Rust-based, mínimo overhead |
| **Tunnelmole** | Gratuito | NPM ou binário | **Alternativa direta ao ngrok** | HTTP/HTTPS | Não | Interface familiar, fácil uso |
| **FRP (Fast Reverse Proxy)** | Open-source | Binário Go | **Alta performance** | HTTP/HTTPS, TCP, UDP | Não | Servidor próprio, muito configurável |
| **SirTunnel** | Gratuito | Docker/Node.js | **Dashboard web integrado** | HTTP/HTTPS | Não | Interface amigável, multi-túnel |
| **LocalXpose** | Gratuito (com limites) | Binário Go | **Similar ao ngrok** | HTTP/HTTPS, TCP | Sim | Recursos avançados no gratuito |

## 🔍 Guia de Escolha da Ferramenta Ideal

### 1. **Para que você precisa do túnel?**
- **Teste rápido e único** (mostrar para colega): → **`localhost.run`**
- **Desenvolvimento contínuo/Webhooks**: → **Cloudflare Tunnel** ou **Pinggy**
- **Controle total/Self-hosting**: → **Zrok** ou **FRP**
- **Evitar Node.js**: → **localhost.run** (SSH) ou **PageKite** (Python)

### 2. **Considerações técnicas**
- **Restrições de firewall**: SSH (porta 443) geralmente funciona melhor
- **Performance necessária**: Cloudflare tem rede global otimizada
- **Persistência do domínio**: Alguns serviços oferecem subdomínios estáveis
- **Suporte a protocolos**: Verifique se precisa de TCP/UDP além de HTTP

### 3. **Recomendações por cenário**
- **Melhor custo-benefício geral**: `localhost.run`
- **Mais profissional/robusto**: Cloudflare Tunnel  
- **Mais simples para iniciantes**: Tunnelmole
- **Mais controle/configuração**: FRP

## 🛠️ Preparação do Ambiente

### Configurando um Servidor Local Básico

#### Exemplo de Estrutura de Pastas:
```bash
projeto-demo/
├── index.html
├── style.css
├── script.js
├── api/
│   └── data.json
└── imagens/
    └── logo.png
```

#### Opções de Servidores Locais:

```bash
#!/bin/bash
# Opção 1: Servidor Python (recomendado para iniciantes)
cd ~/projeto-demo
python3 -m http.server 8080

# Opção 2: Servidor Python com diretório específico
python3 -m http.server 8080 --directory /caminho/da/pasta

# Opção 3: Servidor PHP (se instalado)
php -S localhost:8080

# Opção 4: Servidor Node.js simples
npx serve . -p 8080

# Opção 5: Servidor com bind específico
python3 -m http.server 8080 --bind 0.0.0.0  # Acessível por qualquer IP
```

#### Criando um Projeto de Teste Rápido:
```bash
#!/bin/bash
# Crie uma estrutura básica para testes
mkdir meu-teste && cd meu-teste

# Crie arquivos básicos
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Servidor de Teste</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <h1>✅ Servidor Funcionando!</h1>
    <p>Status: <span class="status">Online</span></p>
    <p>URL Pública: <code id="url">Carregando...</code></p>
    <script>
        document.getElementById('url').textContent = window.location.href;
    </script>
</body>
</html>
EOF

# Inicie o servidor
python3 -m http.server 8080
```

#### Verificando se o Servidor Está Funcionando:
```bash
# Teste localmente
curl http://localhost:8080

# Ou abra no navegador:
# http://localhost:8080
```

## 🚀 Tutoriais Práticos

### Tutorial 1: Pinggy (Recomendado para Testes Rápidos)

```bash
#!/bin/bash
# PASSO 1: Preparar servidor local
# Navegue até a pasta que deseja compartilhar
cd ~/meu-projeto
python3 -m http.server 8080

# PASSO 2: Em OUTRO terminal, criar túnel
ssh -p 443 -R0:localhost:8080 a.pinggy.io

# PASSO 3: Usar o terminal interativo do Pinggy
# Após conectar, você verá:
# 1. URL pública (ex: https://abc123.pinggy.link)
# 2. Pressione 'i' para ver requisições em tempo real
# 3. Pressione 'h' para ajuda com comandos
# 4. Pressione 't' para ver estatísticas

# DICA: Para URL mais curta, use:
ssh -p 443 -R0:localhost:8080 a.pinggy.io -- -subdomain=meuteste
```

### Tutorial 2: localhost.run (O Mais Simples)

```bash
#!/bin/bash
# Expor servidor na porta 3000
ssh -R 80:localhost:3000 localhost.run

# Com subdomínio personalizado (se disponível)
ssh -R 80:localhost:3000 ssh.localhost.run

# Expor múltiplas portas
ssh -R 80:localhost:3000 -R 8080:localhost:8080 localhost.run

# Manter túnel ativo mesmo com desconexão SSH
ssh -o ServerAliveInterval=60 -R 80:localhost:3000 localhost.run
```

### Tutorial 3: Cloudflare Tunnel (Para Uso Profissional)

```bash
#!/bin/bash
# 1. Instalação
# Linux:
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared-linux-amd64
sudo mv cloudflared-linux-amd64 /usr/local/bin/cloudflared

# 2. Autenticar (abre navegador para login)
cloudflared tunnel login

# 3. Criar túnel
cloudflared tunnel create meu-tunel

# 4. Configurar (editar arquivo config.yml)
# O arquivo estará em ~/.cloudflared/config.yml

# 5. Iniciar túnel
cloudflared tunnel run meu-tunel

# 6. Roteamento DNS (opcional)
cloudflared tunnel route dns meu-tunel subdominio.seudominio.com
```

### Tutorial 4: Tunnelmole (Alternativa ao Ngrok)

```bash
#!/bin/bash
# Instalação via npm
npm install -g tunnelmole

# Uso básico
tunnelmole 8080

# Com subdomínio específico
tunnelmole 8080 --subdomain meuservidor

# Para obter URL HTTPS
tunnelmole 8080 --https

# Mostrar status
tunnelmole status
```

### Tutorial 5: FRP - Auto-hospedado (Controle Total)

```bash
#!/bin/bash
# ===== NO SERVIDOR REMOTO (VPS) =====
# 1. Download
wget https://github.com/fatedier/frp/releases/download/v0.51.3/frp_0.51.3_linux_amd64.tar.gz
tar -xzf frp_0.51.3_linux_amd64.tar.gz
cd frp_0.51.3_linux_amd64

# 2. Configurar servidor (frps.ini)
cat > frps.ini << EOF
[common]
bind_port = 7000
vhost_http_port = 8080
vhost_https_port = 8443
dashboard_port = 7500
dashboard_user = admin
dashboard_pwd = senhasegura
token = meutokenseguro
EOF

# 3. Iniciar servidor
./frps -c frps.ini

# ===== NA SUA MÁQUINA LOCAL =====
# 4. Configurar cliente (frpc.ini)
cat > frpc.ini << EOF
[common]
server_addr = SEU_IP_DO_SERVIDOR
server_port = 7000
token = meutokenseguro

[web]
type = http
local_ip = 127.0.0.1
local_port = 8080
custom_domains = app.seudominio.com

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000
EOF

# 5. Iniciar cliente
./frpc -c frpc.ini
```

## 💡 Casos de Uso Comuns

### 1. **Desenvolvimento Frontend**
```bash
#!/bin/bash
# React/Vue/Next.js
npm run dev  # Porta 3000
ssh -R 80:localhost:3000 localhost.run

# Com hot reload funcionando
npm run dev & ssh -R 80:localhost:3000 localhost.run
```

### 2. **Testes de Webhook e API**
```bash
#!/bin/bash
# API local em Flask/Django/Express
python app.py  # Porta 5000

# Em outro terminal:
ssh -p 443 -R0:localhost:5000 a.pinggy.io

# Agora webhooks externos podem acessar:
# https://seuid.pinggy.io/api/webhook
```

### 3. **Acesso a Ferramentas de Administração**
```bash
#!/bin/bash
# Expor painel do Portainer (Docker)
docker run -d -p 9000:9000 portainer/portainer
ssh -R 80:localhost:9000 localhost.run

# Home Assistant
ssh -R 80:localhost:8123 localhost.run
```

### 4. **Demonstração para Cliente**
```bash
#!/bin/bash
# Gerar build de produção e servir
npm run build
npx serve -s build -p 8080
cloudflared tunnel --url http://localhost:8080
```

## 🔒 Boas Práticas e Segurança

### ⚠️ **Atenção Crítica**
1. **Nunca exponha serviços de produção**
2. **Use autenticação em tudo** que for exposto
3. **Limite o tempo** do túnel aberto
4. **Monitore as conexões** ativas
5. **Use HTTPS** sempre que possível

### Configurações Seguras

```bash
#!/bin/bash
# Com autenticação HTTP básica
# Para Python, use:
python3 -m http.server 8080 --username admin --password senhaforte

# Para túneis com autenticação
ssh -R 80:localhost:8080 localhost.run --auth "usuario:senha"

# Túnel com tempo limite (2 horas)
timeout 7200 ssh -R 80:localhost:8080 localhost.run
```

### Script de Segurança Básico
```bash
#!/bin/bash
# secure_tunnel.sh - Túnel com proteções básicas

PORT=${1:-8080}
TIMEOUT=3600  # 1 hora
LOG_FILE="/tmp/tunnel_$(date +%Y%m%d_%H%M%S).log"

echo "Iniciando túnel seguro na porta $PORT"
echo "Log: $LOG_FILE"
echo "Tempo limite: $TIMEOUT segundos"

# Verificar se porta está em uso
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "ERRO: Porta $PORT já está em uso!"
    exit 1
fi

# Iniciar túnel com timeout
timeout $TIMEOUT ssh -o ExitOnForwardFailure=yes \
                     -o ServerAliveInterval=30 \
                     -o ServerAliveCountMax=3 \
                     -R 80:localhost:$PORT \
                     localhost.run 2>&1 | tee "$LOG_FILE"

echo "Túnel encerrado após $TIMEOUT segundos"
```

### Serviços que NUNCA devem ser Expostos:
- ✅ **PODE**: Aplicações de desenvolvimento, testes, demonstrações
- ❌ **NÃO PODE**:
  - SSH da sua máquina principal
  - Banco de dados de produção
  - Painéis admin sem autenticação
  - Serviços com falhas de segurança conhecidas
  - Qualquer coisa com dados sensíveis

## ❓ Perguntas Frequentes

### **P: Meu túnel cai frequentemente. Como resolver?**
**R:** Tente estas soluções:
```bash
#!/bin/bash
# 1. Usar keepalive
ssh -o ServerAliveInterval=30 -o ServerAliveCountMax=3 ...

# 2. Script de reconexão automática
while true; do
    ssh -R 80:localhost:8080 localhost.run
    sleep 5
done

# 3. Usar serviço mais estável (Cloudflare)
```

### **P: Posso usar domínio próprio gratuito?**
**R:** Sim, algumas opções:
1. **Cloudflare Tunnel**: Domínios gerenciados pela Cloudflare
2. **DuckDNS**: Domínio gratuito dinâmico
3. **No-IP**: Oferece domínio gratuito básico

### **P: Como saber qual porta meu app está usando?**
**R:**
```bash
# Para aplicações web comuns:
# React: 3000    Vue: 8080    Angular: 4200
# Flask: 5000    Django: 8000    Express: 3000

# Verificar portas em uso:
sudo netstat -tulpn | grep LISTEN
# ou
sudo lsof -i -P -n | grep LISTEN
```

### **P: Túnel funciona atrás de NAT/roteador?**
**R:** Sim! Essa é a principal vantagem. Os túneis criam uma conexão de dentro para fora, contornando limitações de NAT.

### **P: Há limite de banda nos planos gratuitos?**
**R:** Geralmente sim, mas generosos:
- **Cloudflare**: ~100GB/mês
- **localhost.run**: Sem limite conhecido
- **Pinggy**: Limitado para testes
- **Tunnelmole**: 1GB/mês no gratuito

## 🚨 Solução de Problemas

### Problemas Comuns:

```bash
#!/bin/bash
# 1. "Connection refused" quando tenta acessar URL
# Solução: Verifique se o servidor local está rodando
curl http://localhost:8080  # Deve retornar algo

# 2. "Port already in use"
# Solução: Mude a porta ou mate o processo
sudo lsof -ti:8080 | xargs kill -9
python3 -m http.server 8081

# 3. SSH pede senha repetidamente
# Solução: Verifique permissões da chave SSH
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 4. Túnel conecta mas não carrega a página
# Solução: Verifique firewalls
sudo ufw allow 8080/tcp  # Para Ubuntu
```

### Comandos de Diagnóstico:
```bash
#!/bin/bash
# Testar conectividade básica
ping -c 4 localhost.run

# Verificar se porta está aberta localmente
nc -zv localhost 8080

# Testar túnel com curl
curl -I https://seutunel.pinggy.io

# Monitorar conexões em tempo real
watch -n 1 "netstat -an | grep ESTABLISHED"
```

## 📚 Recursos Adicionais

### Ferramentas Complementares Úteis

```bash
# 1. Ngrok (alternativa paga popular)
# https://ngrok.com/ (tem plano gratuito limitado)

# 2. Serveo (alternativa SSH-based)
ssh -R 80:localhost:8080 serveo.net

# 3. Beeceptor (para mock de APIs)
# Ótimo para testar webhooks: https://beeceptor.com

# 4. Pipedream (automação + webhooks)
# Permite criar endpoints rapidamente
```

### Scripts Automatizados

```bash
#!/bin/bash
# auto_tunnel.sh - Automatiza criação de túneis
set -e

APP_PORT=${1:-3000}
TUNNEL_TYPE=${2:-localhost}

case $TUNNEL_TYPE in
    "localhost")
        echo "Iniciando localhost.run na porta $APP_PORT"
        ssh -R 80:localhost:$APP_PORT localhost.run
        ;;
    "pinggy")
        echo "Iniciando Pinggy na porta $APP_PORT"
        ssh -p 443 -R0:localhost:$APP_PORT a.pinggy.io
        ;;
    "cloudflare")
        echo "Iniciando Cloudflare Tunnel"
        cloudflared tunnel --url http://localhost:$APP_PORT
        ;;
    *)
        echo "Tipo desconhecido. Use: localhost, pinggy, cloudflare"
        exit 1
        ;;
esac
```

### Monitoramento Básico
```python
#!/bin/python
# monitor_tunnel.py
import requests
import time
from datetime import datetime

def monitor_tunnel(url, interval=60):
    """Monitora status do túnel"""
    while True:
        try:
            response = requests.get(url, timeout=10)
            status = "✅ ONLINE" if response.status_code == 200 else "⚠️  PROBLEM"
            print(f"{datetime.now()} - {status} - {url}")
        except Exception as e:
            print(f"{datetime.now()} - ❌ OFFLINE - {url} - Erro: {e}")
        
        time.sleep(interval)

if __name__ == "__main__":
    # Use: python monitor_tunnel.py
    monitor_tunnel("https://seutunel.pinggy.io")
```

---

## 🎯 Conclusão

### Resumo das Recomendações:

| Cenário | Ferramenta Recomendada | Por quê? |
|---------|----------------------|----------|
| **Teste rápido** | `localhost.run` | Zero instalação, mais simples |
| **Desenvolvimento contínuo** | **Cloudflare Tunnel** | Estável, com analytics |
| **Debug detalhado** | **Pinggy** | Terminal interativo com inspeção |
| **Controle total** | **FRP** | Auto-hospedado, configuração completa |
| **Alternativa ao ngrok** | **Tunnelmole** | Interface familiar, fácil migração |

### Próximos Passos:

1. **Comece simples**: Teste com `localhost.run` primeiro
2. **Evolua conforme necessidade**: Migre para Cloudflare quando precisar de mais features
3. **Considere auto-hospedar**: Se precisar de controle total, use FRP
4. **Sempre priorize segurança**: Nunca exponha serviços sensíveis

### Checklist Antes de Compartilhar:
- [ ] Servidor local está funcionando (`curl localhost:PORT`)
- [ ] Túnel criado com sucesso
- [ ] URL pública acessível
- [ ] Autenticação configurada (se necessário)
- [ ] Dados sensíveis removidos/ocultados

---

**📞 Suporte Comunitário**:  
Encontrou um problema? Consulte as issues no GitHub do projeto ou pergunte em fóruns como Stack Overflow.

**🔄 Atualizações**:  
Este guia é atualizado regularmente. Verifique a data da última revisão e consulte os repositórios oficiais para informações mais recentes.

**🤝 Contribua**:  
Encontrou um erro? Tem uma sugestão? Contribua com o projeto ou abra uma issue!

---

*Última atualização: Janeiro 2026*  
*Licença: CC BY-SA 4.0 - Sinta-se à vontade para compartilhar e adaptar, com atribuição.*