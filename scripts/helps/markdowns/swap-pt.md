# Guia de Configuração de Arquivo de Swap no Arch Linux

Para ativar uma área de **swap** no Arch Linux, você pode criar um arquivo de swap. Esta é uma solução flexível que não requer particionamento de disco.

Aqui estão as etapas principais:

1.  **Criar o arquivo**: Use o comando `fallocate` para criar um arquivo no sistema de arquivos. Por exemplo, para criar um arquivo de **4 GB** no diretório raiz (`/`):
    ```bash
    sudo fallocate -l 4G /swapfile
    ```
    *   Se o `fallocate` tiver problemas, você pode usar o comando `dd` como alternativa.
    ```bash
    sudo dd if=/dev/zero of=/swapfile bs=4M count=1024 oflag=direct,dsync status=progress && sync
    ```

2.  **Ajustar permissões**: Por segurança, restrinja o acesso ao arquivo para que apenas o usuário **root** possa ler e escrever nele:
    ```bash
    sudo chmod 600 /swapfile
    ```

3.  **Formatar como swap**: Prepare o arquivo para ser usado como área de swap:
    ```bash
    sudo mkswap /swapfile
    ```

4.  **Ativar o swap**: Disponibilize o arquivo de swap para o sistema usar imediatamente:
    ```bash
    sudo swapon /swapfile
    ```

5.  **Tornar a ativação permanente**: Para que o swap seja ativado automaticamente em toda inicialização, adicione uma linha ao arquivo `/etc/fstab`. Use um editor de texto como `nano` ou `vim`:
    ```bash
    sudo nano /etc/fstab
    ```
    Adicione a seguinte linha no final do arquivo:
    ```
    /swapfile none swap defaults 0 0
    ```
    Salve e feche o editor.

### Como verificar se o swap está ativo
Após seguir as etapas, verifique se o swap está funcionando com um destes comandos:
*   `swapon --show` (mostra os dispositivos de swap ativos)
*   `free -h` (mostra o uso de memória e swap em formato legível)

### 💡 Considerações importantes
*   **Tamanho do swap**: Um tamanho comum é igual à quantidade de **RAM** do sistema (ex.: 16 GB de RAM = 16 GB de swap). Se você tiver muita RAM (ex.: 32 GB), pode usar menos.
*   **Hibernação (suspend-to-disk)**: Se você planeja usar **hibernação**, o arquivo de swap (ou partição) deve ter um tamanho **pelo menos igual à sua RAM total**. Configurar a hibernação envolve ajustes adicionais no gerenciador de inicialização (como GRUB).
*   **Swap vs. RAM**: O swap é útil para evitar travamentos quando a RAM se esgota e para dar mais flexibilidade ao kernel no gerenciamento de memória. No entanto, é muito mais lento que a RAM. Se seu sistema usar swap constantemente, a melhor solução é aumentar a memória física.
*   **Desativar o swap**: Se necessário, você pode desativar tudo com `sudo swapoff -a` e depois remover a linha correspondente do arquivo `/etc/fstab`.

### 🔍 E quanto a outros métodos (zram, zswap)?
Os resultados da pesquisa mencionam alternativas modernas:
*   **zram**: Cria um dispositivo de swap **comprimido na própria RAM**, aumentando a memória efetiva. É uma boa opção para sistemas com RAM limitada, mas **não pode ser usado para hibernação**, pois os dados são perdidos no desligamento.
*   **zswap**: Atua como uma **camada de cache comprimida** para o swap físico (arquivo ou partição). O kernel tenta comprimir páginas de memória antes de enviá-las para o disco, o que pode melhorar o desempenho. Geralmente, você **não usa zram e zswap ao mesmo tempo**, pois são redundantes.

Qual método você pretende usar? Se você me contar um pouco sobre sua configuração (quantidade de RAM e se precisa de hibernação), posso dar recomendações mais específicas.

---

# Configurar o Swap para Ativar Apenas como Último Recurso

Para fazer o **swap ativar apenas como último recurso**, você precisa ajustar o parâmetro **"swappiness"**, que controla a disposição do kernel em usar a área de swap em vez da RAM. No Arch Linux, o valor padrão é `60` (em uma escala de 0-100), o que significa que o kernel começará a usar swap quando cerca de **40% da RAM estiver livre**.

## 🎯 Passo 1: Verificar o swappiness atual
```bash
cat /proc/sys/vm/swappiness
```
Se mostrar `60`, o sistema está configurado para usar swap relativamente cedo.

## 📉 Passo 2: Reduzir o swappiness (recomendado: 10-20)
Um valor baixo (ex.: `10`) faz o kernel usar o swap **somente quando realmente necessário**:
```bash
# Alterar temporariamente (válido até a reinicialização)
sudo sysctl vm.swappiness=10

# Alterar permanentemente
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
```
- **10-20**: Ideal para desktops/servidores com RAM suficiente
- **1-5**: Apenas em emergências extremas (pode acionar o OOM killer)
- **60**: Padrão para Arch/Ubuntu
- **80**: Servidores de banco de dados

## 🔄 Passo 3: Ajustar também o cache de arquivos (vfs_cache_pressure)
Outro parâmetro importante que afeta o comportamento da memória:
```bash
# Reduzir para que o kernel retenha mais cache de arquivos (padrão=100)
sudo sysctl vm.vfs_cache_pressure=50
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.d/99-swappiness.conf
```
Valor mais baixo (50) = kernel mantém mais cache na RAM = menos necessidade de swap.

## ✅ Passo 4: Verificar os ajustes
```bash
# Recarregar configurações
sudo sysctl --system

# Verificar valores atuais
cat /proc/sys/vm/swappiness
cat /proc/sys/vm/vfs_cache_pressure
```

## 📊 Passo 5: Monitorar o uso real
Após ajustar, monitore como o sistema se comporta:
```bash
# Verificar uso de memória/swap
free -h

# Monitorar em tempo real (Ctrl+C para sair)
watch -n 1 "free -h | grep -E 'total|Mem|Swap'"

# Alternativa mais detalhada
htop  # ou top (pressione 'M' para ordenar por uso de RAM)
```

## 🛠️ Considerações adicionais

### ⚡ **Para sistemas SSD/NVMe**
Se seu swap estiver em um SSD, um swappiness baixo é ainda mais eficaz - o swap rápido não degrada tanto o desempenho quando usado.

### 🌙 **Hibernação com swappiness baixo**
Se você usar hibernação (`suspend-to-disk`):
1. O swappiness baixo **não interfere** na hibernação
2. O sistema ainda copiará toda a RAM para o swap durante a hibernação
3. Apenas certifique-se de que o swap tenha **pelo menos o tamanho da sua RAM**

### ⚠️ **Sinais de que o valor está muito baixo**
Se você começar a ver:
- Aplicativos fechando abruptamente (OOM killer)
- Sistema travando quando a RAM está cheia
- Mensagens de `out of memory` nos logs (`journalctl -k`)

Neste caso, aumente gradualmente para `15` ou `20`.

### 🔄 **Teste prático**
Para testar como seu sistema responde:
1. Abra vários aplicativos pesados (navegador com muitas abas, virtualização, etc.)
2. Use `free -h` ou `htop` para ver se o swap está sendo usado
3. Com `swappiness=10`, o swap só deve aparecer quando a RAM estiver >90% usada

**Você já tem swap configurado como arquivo ou partição?** Se quiser verificar, execute `swapon --show` - isso me ajuda a dar recomendações mais precisas sobre o tamanho ideal considerando seu uso.