# Waydroid para iniciantes: Guia Completo para Configuração e Uso

Este guia aborda desde a instalação básica no Arch Linux até tópicos avançados como compatibilidade com apps ARM, root com Magisk, compartilhamento de arquivos e solução de problemas.

## ⚙️ Pré-requisitos e Instalação no Arch Linux

### Verificando e Instalando Módulos do Kernel

O Waydroid requer os módulos do kernel `binder_linux` e `ashmem_linux`. Muitos kernels populares já os incluem por padrão:

*   **`linux-zen`** (kernel padrão do Garuda Linux)
*   **`linux-cachyos`** (disponível no chaotic-aur)
*   **`linux-xanmod`** (disponível no chaotic-aur)

Para verificar se seu kernel já possui os módulos, execute:
```bash
sudo modprobe -a binder_linux
```
Se o comando retornar sem erros, os módulos estão presentes. Caso contrário, você pode instalá-los via DKMS:
```bash
sudo pacman -S binder_linux-dkms
```

### Instalação do Waydroid

O Waydroid está disponível no **chaotic-aur**. Após configurar o repositório, instale o pacote:
```bash
sudo pacman -Syu waydroid
```

## 🚀 Inicialização e Primeiros Passos

1.  **Inicialize o Waydroid**. Para uma experiência com a Google Play Store, use a flag `-s GAPPS`:
    ```bash
    sudo waydroid init -s GAPPS
    ```
    *Isso baixará as imagens do sistema Android. Em algumas regiões, usar uma VPN para um país europeu pode acelerar o download.*

2.  **Habilite e inicie o serviço do contêiner**:
    ```bash
    sudo systemctl enable --now waydroid-container
    ```

3.  **Inicie a sessão** (sem usar `sudo`):
    ```bash
    waydroid session start
    ```

4.  **Abra a interface completa** do Android ou inicie aplicativos pelo menu de aplicativos do seu desktop:
    ```bash
    waydroid show-full-ui
    ```

## 📁 Compartilhamento de Arquivos entre Host e Android

Configure um diretório compartilhado para transferir arquivos entre seu sistema Arch e o ambiente Android:

```bash
# Criar diretórios
sudo mkdir -p /var/lib/waydroid/data/media/0/Share
mkdir -p ~/Public/Android

# Montar compartilhamento
sudo mount --bind -o rw /var/lib/waydroid/data/media/0/Share ~/Public/Android
```

### Script de Inicialização Automatizado

Para automatizar o processo de inicialização e compartilhamento, você pode usar um script como este:

```bash
#!/bin/bash

# Directory configurations
waydroid_share="$HOME/.local/share/waydroid/data/media/0/Share"
waydroid_mount="$HOME/Public/Android"

# Check if Waydroid container is running
waydroid_container=$(pgrep -f waydroid)
waydroid_process=$(pidof waydroid)

# Manage Waydroid service
if [[ -n "${waydroid_container}" ]]; then 
    echo -n "Waydroid service detected. Restart? (y/n): "    
    read -r response
    if [[ "${response}" =~ ^[Yy]$ ]]; then 
        sudo systemctl stop waydroid-container.service
        clear
    fi
fi

# Waydroid initialization
if [ -z "${waydroid_container}" ]; then 
    echo "Starting Waydroid initialization..."
    sudo waydroid init -s GAPPS -f & disown
fi

# First-time setup
if [ -z "${waydroid_process}" ]; then 
    echo "Running first-time setup..."
    waydroid first-launch 2>/dev/null & disown
fi

# File sharing configuration
echo "Configuring file sharing..."
if ! sudo ls "${waydroid_share}" >/dev/null 2>&1; then
    sudo mkdir -p "${waydroid_share}"
    # Change ownership of the share directory to the current user
	sudo chmod -R 755 "${waydroid_share}"
    sudo chown -R "${USER}" "${waydroid_share}"
fi

if [[ ! -d "${waydroid_mount}" ]]; then
    mkdir -p "${waydroid_mount}"
fi

# Mount shared directory
sudo mount --bind -o rw "${waydroid_share}" "${waydroid_mount}"
sudo chown -R "${USER}" "${waydroid_mount}"

echo "Waydroid setup completed successfully!"
```

## 🔧 Funcionalidades Avançadas com `waydroid-script-git`

O `waydroid-extras` (instalável via `waydroid-script-git`) é uma ferramenta essencial para estender as capacidades do Waydroid.

### Instalação do Script

Instale o pacote do AUR usando um helper como o `yay`:
```bash
yay -S waydroid-script-git
```
Após a instalação, execute o script com direitos administrativos:
```bash
sudo waydroid-extras
```

### Principais Funcionalidades do waydroid-extras

#### Bibliotecas de Tradução ARM (`libhoudini` e `libndk`)

Para executar aplicativos compilados exclusivamente para ARM em processadores x86_64:

| Biblioteca | Descrição | Performance Recomendada |
| :--- | :--- | :--- |
| **libhoudini** | Biblioteca de tradução da Intel para CPUs Intel/AMD x86 | Melhor desempenho em CPUs **Intel** |
| **libndk** | Tradução do Google a partir do Chromium OS | Melhor desempenho em CPUs **AMD** |

**Importante**: Instale apenas uma biblioteca de cada vez, pois elas são mutuamente exclusivas.

#### Google Play Store e Serviços Google

O script permite instalar ou reinstalar os serviços Google (GApps) caso você tenha inicializado o Waydroid sem a flag GAPPS.

#### Root com Magisk

Para obter acesso root no ambiente Waydroid:
```bash
sudo waydroid-extras
```
Selecione a opção Magisk no menu. Note que alguns módulos avançados podem não funcionar devido às limitações do ambiente containerizado.

#### Widevine para Streaming

Habilite o suporte a DRM para assistir conteúdo em serviços como Netflix, Amazon Prime Video e Disney+ diretamente no navegador Android do Waydroid.

## 📱 Gerenciamento de Aplicativos

### Comandos Principais do Waydroid

- **Instalar aplicativo**:
  ```bash
  waydroid app install caminho/para/app.apk
  ```

- **Listar aplicativos instalados**:
  ```bash
  waydroid app list
  ```

- **Iniciar aplicativo** (conhecendo o nome do pacote):
  ```bash
  waydroid app launch com.pacote.app
  ```

- **Remover aplicativo**:
  ```bash
  waydroid app remove com.pacote.app
  ```

### Obter Android ID para Google Play Store

Para registrar seu dispositivo Waydroid na Google Play Store:

```bash
sudo waydroid shell -- sh -c "sqlite3 /data/data/com.google.android.gsf/databases/gservices.db 'select * from main where name = \"android_id\";'"
```

Ou alternativamente:
```bash
sudo waydroid shell
# Dentro do shell do Waydroid:
ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
```

Visite https://www.google.com/android/uncertified/ e registre o número gerado.

## 🛠️ Solução de Problemas Comuns

### Problema de Rede Wi-Fi

Se o Waydroid mostra rede Wi-Fi desativada:

```bash
# Parar Waydroid
sudo waydroid session stop
sudo waydroid container stop

# Configurar firewall para permitir tráfego DNS
sudo ufw allow 67
sudo ufw allow 53
sudo ufw default allow FORWARD

# Reiniciar Waydroid
sudo systemctl restart waydroid-container
```

### Problemas com Nvidia e Máquinas Virtuais

*   **GPUs Nvidia (exceto Tegra)**: Pode ser necessário usar renderização por software
*   **Máquinas virtuais**: Verifique se a virtualização aninhada está habilitada

### Vídeos Não Reproduzem (Tela Preta)

Problema conhecido em placas Nvidia. Soluções possíveis:
- Alternar para o driver `xorg`
- Remover configurações personalizadas
- Aguardar atualizações futuras que corrigem o callback de áudio

### Reinstalação Completa

Se encontrar problemas graves:

```bash
# Parar serviços
waydroid session stop
sudo waydroid container stop

# Remover pacote
sudo pacman -R waydroid

# Limpar dados residuais
sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/applications/*aydroid* ~/.local/share/waydroid

# Reiniciar e reinstalar
sudo reboot
```

## 💡 Comandos Úteis e Dicas

### Atualização do Sistema
```bash
waydroid upgrade  # Atualiza a imagem Android
```

### Modo Multijanela
Para executar apps em janelas individuais redimensionáveis:
```bash
waydroid prop set persist.waydroid.multi_windows true
waydroid session stop
# Reinicie a sessão Waydroid após
```

### Shell do Android
Acesse o terminal do Android diretamente:
```bash
waydroid shell
```

### Reinício Rápido do Container
```bash
sudo systemctl restart waydroid-container
```

## 📚 Recursos Adicionais

*   **Documentação Oficial**: [docs.waydro.id](https://docs.waydro.id/)
*   **GitHub**: [github.com/waydroid/waydroid](https://github.com/waydroid/waydroid)
*   **Arch Wiki**: [wiki.archlinux.org/title/Waydroid](https://wiki.archlinux.org/title/Waydroid)

---

*Este guia incorpora as melhores práticas para o Arch Linux, incluindo configurações de compartilhamento de arquivos, uso do waydroid-script-git para funcionalidades avançadas, e soluções para problemas comuns encontrados pela comunidade.*