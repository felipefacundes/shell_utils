#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

clear

declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then
    MESSAGES=(
        ["intuitive_install"]="Uma maneira intuitiva de instalar o ArchLinux"
        ["connect_internet"]="Passo 01 - Conectar à Internet"
        ["check_wifi_interface"]="Verifique a interface de rede Wifi"
        ["enter_iwd_interface"]="Digite a interface IWD"
        ["type_commands_inside_interface"]="Dentro da interface, digite os seguintes comandos:"
        ["start_searching_network"]="Para começar a buscar a rede, assumindo que seu dispositivo é 'wlan0'"
        ["list_available_networks"]="Para listar as redes disponíveis (SSID)"
        ["finally_connecting_internet"]="Finalmente, conectando à Internet"
        ["optional_step_backup"]="Passo opcional - Backup - Para reinstalação do sistema sem formatação"
        ["backup_can_be"]="O BACKUP PODE SER, PARA UMA LISTA."
        ["reinstall_downloading_packages"]=" - Para uma reinstalação, baixando os pacotes novamente:"
        ["read_command_02_lines"]="Leia. Na linha abaixo, contém '2' linhas de comando, obedeça a cada comando:"
        ["read_command_03_lines"]="Leia. Na linha abaixo, contém '3' linhas de comando, obedeça a cada comando:"
        ["read_command_07_lines"]="Leia. Na linha abaixo, contém '7' linhas de comando, obedeça a cada comando:"
        ["reuse_existing_packages"]="OU VOCÊ PODE REUTILIZAR PACOTES EXISTENTES DO SEU HD COM ESTE MÉTODO:"
        ["first_mount_root_partition"]="Primeiro, monte a partição raiz (/)"
        ["analyze_subvolume_interfering"]="Analise se há subvolume interferindo:"
        ["backup_existing_packages_cache"]="Faça backup dos pacotes existentes no cache:"
        ["step_02_partitioning_formatting"]="Passo 02 - Particionamento e Formatação:"
        ["partition_hd"]="Particione o HD"
        ["create_sda1_partition"]="Crie 'sda1' 250MB para boot - Se for 'UEFI', a partição de 'BOOT' deve ser em 'FAT'"
        ["create_sda2_partition"]="Crie 'sda2', uma partição para a raiz (/) do sistema (root) de pelo menos 30GB."
        ["create_sda3_partition"]="Crie 'sda3' 512MB ou 3GB para swap/ '3GB se você quiser modo de suspensão' - pode ser um tamanho maior, até o mesmo número da sua RAM."
        ["to_partition_use_commands"]="Para particionar, use estes comandos:"
        ["to_check_existing_partitions"]="Para verificar as partições existentes:"
        ["to_zero_hd_create_partition_table"]="Para zerar rapidamente o HD e criar uma nova tabela de partições:"
        ["to_create_partitions_existing_table"]="Para apenas criar partições dentro de uma tabela de partições existente:"
        ["another_partitioner_text_mode"]="Para outro particionador em modo texto, muito eficiente, na minha opinião o melhor: 'parted'"
        ["properly_format_linux_partitions"]="Para formatar corretamente cada partição linux. Formate em ext4 64Bits ou XFS."
        ["in"]="em"
        ["or"]="Ou:"
        ["else"]="Senão:"
        ["example"]="Exemplo:"
        ["ext4_compatible_desktop"]="'EXT4' é mais 'compatível' com programas de DESKTOP: jogos, etc. Sem mencionar que o ext4 é um sistema maduro, que suporta desligamentos inadequados."
        ["xfs_fastest_file_system"]="Por outro lado, 'XFS' é o sistema de arquivos mais rápido com suporte adequado para SSD's. Igualmente, é um sistema maduro com Journaling."
        ["for_uefi"]="Para 'UEFI':"
        ["boot_partition_fat"]="A partição '/boot' ou '/boot/EFI' já deve estar em 'FAT-12/16/32'."
        ["fat_partition_sizes"]="Vale a pena notar que uma partição 'FAT12' deve ter pelo menos '1M'. Já a 'FAT16' deve ter pelo menos '9M' e a 'FAT32' deve ter pelo menos '33M'."
        ["boot_partition_minimum"]="Se você for usá-lo como '/boot', deve ter pelo menos '250M', enquanto '/boot/EFI' é o mínimo indicado acima correspondente ao tipo de partição 'FAT' escolhido."
        ["use_f12_fat12"]="Use '-F12' para FAT12. Exemplo:"
        ["reduce_cluster_size"]="Use '-s2' para reduzir o tamanho do cluster e tornar a partição legível pelo UEFI."
        ["formatting_example"]="EXEMPLO DE FORMATAÇÃO:"
        ["option_L_assigns_labels"]="A opção '-L' atribui rótulos às partições, o que ajuda a consultá-las mais tarde através de '/dev/disk/by-label' sem precisar lembrar seus números. Agora monte suas partições:"
        ["efi_partition_required"]="Partição EFI, necessária para sistemas EFI."
        ["boot_partition_optional"]="Partição BOOT, é opcional, mas é uma boa prática usar uma partição BOOT separada em caso de erros."
        ["root_part"]="Partição ROOT."
        ["home_part_opt"]="Partição HOME, Opcional."
        ["swap_part_opt"]="Partição SWAP, Opcional."
        ["partition_table_assembly_example"]="EXEMPLO DE MONTAGEM DA TABELA DE PARTIÇÕES, DE ACORDO COM A FORMATAÇÃO ACIMA:"
        ["enable_swap"]="Habilitar SWAP"
        ["mount_root"]="Montando a Partição ROOT"
        ["create_home"]="Criar pasta home"
        ["mount_home"]="Montar Partição HOME"
        ["create_boot_efi"]="Criar pasta boot e EFI"
        ["mount_boot"]="Montar a Partição BOOT"
        ["mount_efi"]="Montar a partição EFI"
        ["step_03_finally_installation"]="Passo 03 - FINALMENTE, VAMOS À INSTALAÇÃO:"
        ["load_keyboard_layout_us"]="Para apenas carregar o layout de teclado para US:"
        ["prepare_base_install_kernel"]="Prepare a base do sistema e instale o kernel"
        ["inside_system_chroot"]="Agora está dentro do sistema (chroot):"
        ["encrypted_hd_instructions"]="Para HDs criptografados (somente se você o criptografou deliberadamente), siga este LINK do meu tutorial:"
        ["install_grub"]="Para que o sistema inicie corretamente, instale o GRUB:"
        ["for_uefi_systems"]="Para sistemas UEFI:"
        ["boot_partition_fat_already_formatted"]="A partição '/boot' ou '/boot/EFI' já deve estar em FAT-12/16/32 (conforme mencionado anteriormente)."
        ["prepare_grub_uefi"]="Agora prepare o GRUB para UEFI:"
        ["efi_partition_separated_boot_efi"]="Se a partição EFI for separada e montada em '/boot/EFI':"
        ["boot_partition_fat_mounted_boot"]="Ou se toda a partição BOOT estiver em FAT e montada em '/boot':"
        ["for_bios_i386_pc"]="Para BIOS (i386-pc):"
        ["force_gpt_partition_table"]="Use '--force' se a tabela de partições for GPT"
        ["use_automation_script"]="Use este script de automação."
        ["finish_with"]="Finalize com:"
        ["dual_boot_rwindows_os_prober"]="Se você tem dual boot com o Windows, instale o 'os-prober' e repita o comando anterior (ou instale-o antes):"
        ["root_password"]="Senha de root"
        ["create_username"]="Crie seu nome de usuário (sem acentos; altere 'YourPreferenceUser' para o nome preferido, ex: 'john')"
        ["create_user_password"]="Criando uma senha para seu usuário:"
        ["edit_sudoers_admin_access"]="Editando SUDOers para ter acesso de administrador:"
        ["edit_sudoers_add_user"]="Procure a linha: 'root ALL=(ALL) ALL'\nAbaixo dela, adicione seu nome de usuário: 'YourPreferenceUser ALL=(ALL) ALL'"
        ["alternative_admin_access_doas_sudo"]="Você também pode usar 'doas' como alternativa ao 'sudo'"
        ["install_xorg"]="Para XORG (essencial para uma interface gráfica):"
        ["dual_boot_windows_use"]="Se você tem dual boot com Windows, use:"
        ["set_hostname"]="Defina seu nome de host:"
        ["for_internet_access"]="Para ter acesso à internet:"
        ["step_04_drivers"]="Passo 04 - Drivers"
        ["enable_multilib_pacman_conf"]="Habilite o Multilib em '/etc/pacman.conf'\nRemova o comentário das linhas '[multilib]' e 'Include = /etc/pacman.d/mirrorlist'"
        ["for_nvidia_drivers"]="Para drivers Nvidia:"
        ["for_intel_driver"]="Para drivers Intel:"
        ["for_amd_drivers"]="Para drivers AMD:"
        ["enable_radv_amdgpu"]="Para habilitar o Radv para sua AMDGPU RADEON, siga meu tutorial super fácil:"
        ["for_audio_driver"]="Para o driver de áudio:"
        ["step_05_desktop"]="Passo 05 - Desktop"
        ["choose_desktop_environment"]="Escolha um ambiente de desktop (KDE, Cinnamon, GNOME, Deepin, XFCE, MATE)"
        ["for_plasma_kde"]="Para Plasma KDE:"
        ["install_cinnamon"]="Para instalar o Cinnamon:"
        ["install_gnome"]="Para instalar o GNOME:"
        ["install_deepin"]="Para instalar o Deepin:"
        ["install_xfce"]="Para instalar o XFCE:"
        ["install_mate"]="Para instalar o MATE:"
        ["step_06_startx"]="Passo 06 - Para quem prefere 'startx' em vez de gerenciadores de exibição (SDDM/GDM/LightDM)"
        ["tty_autologin_getty"]="Para login automático TTY (sem um gerenciador de exibição como LightDM, GDM, SDDM):"
        ["step_07_performance_games_security"]="Passo 07 - Ajustes para Desempenho / Jogos / Segurança"
        ["prepare_games_dependencies"]="Prepare-se para jogos: Instale as dependências necessárias para aumentar consideravelmente o desempenho em jogos."
        ["install_codecs"]="Para codecs (essenciais para suporte multimídia: som e vídeo):"
        ["optimize_system_performance_security"]="Para tornar seu computador mais rápido, eficiente e seguro; melhorar o desempenho e FPS em jogos:"
        ["adjust_limits_conf_performance"]="Em '/etc/security/limits.conf' (melhora o desempenho e FPS em jogos):"
        ["for_notebooks"]="Para notebooks:"
        ["prevent_monitor_sleep"]="Para evitar que seu monitor desligue ou escureça (tela preta):"
        ["step_08_enable_hibernation"]="Passo 08 - Habilitar Hibernação"
        ["for_system_hibernation"]="Para hibernação do sistema (exemplo):"
        ["hibernation_uuid_configuration"]="Configure o UUID para hibernação (veja o exemplo abaixo e use o UUID da saída do comando 'blkid')."
        ["add_resume_hook_mkinitcpio"]="Em '/etc/mkinitcpio.conf', adicione 'resume' ao array 'HOOKS' depois de 'filesystems'."
        ["apply_hibernation_changes"]="Após fazer as alterações, execute os seguintes comandos para habilitar a hibernação:"
        ["hibernation_swapfile_tutorial"]="Se você usa um arquivo de troca (swapfile) para memória virtual e deseja habilitar a hibernação, siga este tutorial:"
        ["step_09_additional_apps_drivers_configs"]="Passo 09 - Aplicativos, Drivers e Configurações Adicionais"
        ["install_printers"]="Para instalar impressoras:"
        ["install_libreoffice"]="Para instalar o LibreOffice:"
        ["install_truetype_fonts"]="Opcional: Instale fontes TrueType para aumentar o número de fontes no seu sistema. Pesquise e instale as fontes de sua preferência."
        ["install_all_fonts_repository"]="Para instalar todas as fontes disponíveis no repositório de uma vez:"
        ["install_these_fonts"]="Ou você também pode instalar estas fontes:"
        ["change_distribution_name"]="Para alterar o nome da sua distribuição (opcional):"
        ["install_yay_for_aur"]="Para usar o AUR (Repositório de Usuários Arch) para programas não encontrados nos repositórios oficiais, instale o yay:"
        ["install_windows_games_playongit"]="Para instalar jogos do Windows no Linux com facilidade, veja o projeto PlayOnGit:"
    )
elif [[ "${LANG,,}" =~ es_ ]]; then
    MESSAGES=(
        ["intuitive_install"]="Una forma intuitiva de instalar ArchLinux"
        ["connect_internet"]="Paso 01 - Conectarse a Internet"
        ["check_wifi_interface"]="Verifique la interfaz de red Wifi"
        ["enter_iwd_interface"]="Ingrese la interfaz IWD"
        ["type_commands_inside_interface"]="Dentro de la interfaz, escriba los siguientes comandos:"
        ["start_searching_network"]="Para comenzar a buscar la red, asumiendo que su dispositivo es 'wlan0'"
        ["list_available_networks"]="Para listar las redes disponibles (SSID)"
        ["finally_connecting_internet"]="Finalmente, conectándose a Internet"
        ["optional_step_backup"]="Paso opcional - Copia de seguridad - Para reinstalar el sistema sin formatear"
        ["backup_can_be"]="LA COPIA DE SEGURIDAD PUEDE SER, PARA UNA LISTA."
        ["reinstall_downloading_packages"]=" - Para una reinstalación, descargando los paquetes nuevamente:"
        ["read_command_02_lines"]="Lea. En la línea de abajo, contiene '2' líneas de comando, obedezca cada comando:"
        ["read_command_03_lines"]="Lea. En la línea de abajo, contiene '3' líneas de comando, obedezca cada comando:"
        ["read_command_07_lines"]="Lea. En la línea de abajo, contiene '7' líneas de comando, obedezca cada comando:"
        ["reuse_existing_packages"]="O PUEDE REUTILIZAR PAQUETES EXISTENTES DE SU HD CON ESTE MÉTODO:"
        ["first_mount_root_partition"]="Primero, monte la partición raíz (/)"
        ["analyze_subvolume_interfering"]="Analice si hay subvolumen interfiriendo:"
        ["backup_existing_packages_cache"]="Haga una copia de seguridad de los paquetes existentes en la caché:"
        ["step_02_partitioning_formatting"]="Paso 02 - Particionamiento y Formateo:"
        ["partition_hd"]="Particione el HD"
        ["create_sda1_partition"]="Cree 'sda1' 250MB para el arranque - Si es 'UEFI', la partición de 'BOOT' debe estar en 'FAT'"
        ["create_sda2_partition"]="Cree 'sda2', una partición para la raíz (/) del sistema (root) de al menos 30GB."
        ["create_sda3_partition"]="Cree 'sda3' 512MB o 3GB para swap/ '3GB si desea el modo de suspensión' - puede ser un tamaño mayor, hasta el mismo número de su RAM."
        ["to_partition_use_commands"]="Para particionar, use estos comandos:"
        ["to_check_existing_partitions"]="Para verificar las particiones existentes:"
        ["to_zero_hd_create_partition_table"]="Para borrar rápidamente el HD y crear una nueva tabla de particiones:"
        ["to_create_partitions_existing_table"]="Para solo crear particiones dentro de una tabla de particiones existente:"
        ["another_partitioner_text_mode"]="Para otro particionador en modo texto, muy eficiente, en mi opinión el mejor: 'parted'"
        ["properly_format_linux_partitions"]="Para formatear correctamente cada partición linux. Formatee en ext4 64Bits o XFS."
        ["in"]="en"
        ["or"]="O:"
        ["else"]="Si no:"
        ["example"]="Ejemplo:"
        ["ext4_compatible_desktop"]="'EXT4' es más 'compatible' con programas de ESCRITORIO: juegos, etc. Sin mencionar que ext4 es un sistema maduro, que soporta apagados inadecuados."
        ["xfs_fastest_file_system"]="Por otro lado, 'XFS' es el sistema de archivos más rápido con soporte adecuado para SSD's. Igualmente, es un sistema maduro con Journaling."
        ["for_uefi"]="Para 'UEFI':"
        ["boot_partition_fat"]="La partición '/boot' o '/boot/EFI' ya debe estar en 'FAT-12/16/32'."
        ["fat_partition_sizes"]="Vale la pena notar que una partición 'FAT12' debe tener al menos '1M'. Ya la 'FAT16' debe tener al menos '9M' y la 'FAT32' debe tener al menos '33M'."
        ["boot_partition_minimum"]="Si va a usarlo como '/boot', debe tener al menos '250M', mientras que '/boot/EFI' es el mínimo indicado arriba correspondiente al tipo de partición 'FAT' elegido."
        ["use_f12_fat12"]="Use '-F12' para FAT12. Ejemplo:"
        ["reduce_cluster_size"]="Use '-s2' para reducir el tamaño del clúster y hacer que la partición sea legible por UEFI."
        ["formatting_example"]="EJEMPLO DE FORMATEO:"
        ["option_L_assigns_labels"]="La opción '-L' asigna etiquetas a las particiones, lo que ayuda a consultarlas más tarde a través de '/dev/disk/by-label' sin necesidad de recordar sus números. Ahora monte sus particiones:"
        ["efi_partition_required"]="Partición EFI, necesaria para sistemas EFI."
        ["boot_partition_optional"]="Partición BOOT, es opcional, pero es una buena práctica usar una partición BOOT separada en caso de errores."
        ["root_part"]="Partición ROOT."
        ["home_part_opt"]="Partición HOME, Opcional."
        ["swap_part_opt"]="Partición SWAP, Opcional."
        ["partition_table_assembly_example"]="EJEMPLO DE MONTAJE DE LA TABLA DE PARTICIONES, DE ACUERDO CON EL FORMATEO ANTERIOR:"
        ["enable_swap"]="Habilitar SWAP"
        ["mount_root"]="Montando la Partición ROOT"
        ["create_home"]="Crear carpeta home"
        ["mount_home"]="Montar Partición HOME"
        ["create_boot_efi"]="Crear carpeta boot y EFI"
        ["mount_boot"]="Montar la Partición BOOT"
        ["mount_efi"]="Montar la partición EFI"
        ["step_03_finally_installation"]="Paso 03 - FINALMENTE, VAMOS A LA INSTALACIÓN:"
        ["load_keyboard_layout_us"]="Para solo cargar el diseño de teclado para US:"
        ["prepare_base_install_kernel"]="Prepare la base del sistema e instale el kernel"
        ["inside_system_chroot"]="Ahora está dentro del sistema (chroot):"
        ["encrypted_hd_instructions"]="Para HDs encriptados (solo si lo encriptó deliberadamente), siga este ENLACE de mi tutorial:"
        ["install_grub"]="Para que el sistema inicie correctamente, instale GRUB:"
        ["for_uefi_systems"]="Para sistemas UEFI:"
        ["boot_partition_fat_already_formatted"]="La partición '/boot' o '/boot/EFI' ya debe estar en FAT-12/16/32 (como se mencionó anteriormente)."
        ["prepare_grub_uefi"]="Ahora prepare GRUB para UEFI:"
        ["efi_partition_separated_boot_efi"]="Si la partición EFI es separada y montada en '/boot/EFI':"
        ["boot_partition_fat_mounted_boot"]="O si toda la partición BOOT está en FAT y montada en '/boot':"
        ["for_bios_i386_pc"]="Para BIOS (i386-pc):"
        ["force_gpt_partition_table"]="Use '--force' si la tabla de particiones es GPT"
        ["use_automation_script"]="Use este script de automatización."
        ["finish_with"]="Finalice con:"
        ["dual_boot_rwindows_os_prober"]="Si tiene dual boot con Windows, instale 'os-prober' y repita el comando anterior (o instálelo antes):"
        ["root_password"]="Contraseña de root"
        ["create_username"]="Cree su nombre de usuario (sin acentos; cambie 'YourPreferenceUser' por el nombre preferido, ej: 'john')"
        ["create_user_password"]="Creando una contraseña para su usuario:"
        ["edit_sudoers_admin_access"]="Editando SUDOers para tener acceso de administrador:"
        ["edit_sudoers_add_user"]="Busque la línea: 'root ALL=(ALL) ALL'\nDebajo de ella, agregue su nombre de usuario: 'YourPreferenceUser ALL=(ALL) ALL'"
        ["alternative_admin_access_doas_sudo"]="También puede usar 'doas' como alternativa a 'sudo'"
        ["install_xorg"]="Para XORG (esencial para una interfaz gráfica):"
        ["dual_boot_windows_use"]="Si tiene dual boot con Windows, use:"
        ["set_hostname"]="Defina su nombre de host:"
        ["for_internet_access"]="Para tener acceso a internet:"
        ["step_04_drivers"]="Paso 04 - Drivers"
        ["enable_multilib_pacman_conf"]="Habilite Multilib en '/etc/pacman.conf'\nRemueva el comentario de las líneas '[multilib]' e 'Include = /etc/pacman.d/mirrorlist'"
        ["for_nvidia_drivers"]="Para drivers Nvidia:"
        ["for_intel_driver"]="Para drivers Intel:"
        ["for_amd_drivers"]="Para drivers AMD:"
        ["enable_radv_amdgpu"]="Para habilitar Radv para su AMDGPU RADEON, siga mi tutorial súper fácil:"
        ["for_audio_driver"]="Para el driver de audio:"
        ["step_05_desktop"]="Paso 05 - Escritorio"
        ["choose_desktop_environment"]="Elija un entorno de escritorio (KDE, Cinnamon, GNOME, Deepin, XFCE, MATE)"
        ["for_plasma_kde"]="Para Plasma KDE:"
        ["install_cinnamon"]="Para instalar Cinnamon:"
        ["install_gnome"]="Para instalar GNOME:"
        ["install_deepin"]="Para instalar Deepin:"
        ["install_xfce"]="Para instalar XFCE:"
        ["install_mate"]="Para instalar MATE:"
        ["step_06_startx"]="Paso 06 - Para quienes prefieren 'startx' en lugar de administradores de pantalla (SDDM/GDM/LightDM)"
        ["tty_autologin_getty"]="Para inicio de sesión automático TTY (sin un administrador de pantalla como LightDM, GDM, SDDM):"
        ["step_07_performance_games_security"]="Paso 07 - Ajustes para Rendimiento / Juegos / Seguridad"
        ["prepare_games_dependencies"]="Prepárese para juegos: Instale las dependencias necesarias para aumentar considerablemente el rendimiento en juegos."
        ["install_codecs"]="Para códecs (esenciales para soporte multimedia: sonido y video):"
        ["optimize_system_performance_security"]="Para que su computadora sea más rápida, eficiente y segura; mejorar el rendimiento y FPS en juegos:"
        ["adjust_limits_conf_performance"]="En '/etc/security/limits.conf' (mejora el rendimiento y FPS en juegos):"
        ["for_notebooks"]="Para notebooks:"
        ["prevent_monitor_sleep"]="Para evitar que su monitor se apague o se oscurezca (pantalla negra):"
        ["step_08_enable_hibernation"]="Paso 08 - Habilitar Hibernación"
        ["for_system_hibernation"]="Para hibernación del sistema (ejemplo):"
        ["hibernation_uuid_configuration"]="Configure el UUID para la hibernación (vea el ejemplo a continuación y use el UUID de la salida del comando 'blkid')."
        ["add_resume_hook_mkinitcpio"]="En '/etc/mkinitcpio.conf', agregue 'resume' al array 'HOOKS' después de 'filesystems'."
        ["apply_hibernation_changes"]="Después de realizar los cambios, ejecute los siguientes comandos para habilitar la hibernación:"
        ["hibernation_swapfile_tutorial"]="Si usa un archivo de intercambio (swapfile) para memoria virtual y desea habilitar la hibernación, siga este tutorial:"
        ["step_09_additional_apps_drivers_configs"]="Paso 09 - Aplicaciones, Drivers y Configuraciones Adicionales"
        ["install_printers"]="Para instalar impresoras:"
        ["install_libreoffice"]="Para instalar LibreOffice:"
        ["install_truetype_fonts"]="Opcional: Instale fuentes TrueType para aumentar el número de fuentes en su sistema. Investigue e instale las fuentes de su preferencia."
        ["install_all_fonts_repository"]="Para instalar todas las fuentes disponibles en el repositorio de una vez:"
        ["install_these_fonts"]="O también puede instalar estas fuentes:"
        ["change_distribution_name"]="Para cambiar el nombre de su distribución (opcional):"
        ["install_yay_for_aur"]="Para usar AUR (Repositorio de Usuarios de Arch) para programas que no se encuentran en los repositorios oficiales, instale yay:"
        ["install_windows_games_playongit"]="Para instalar juegos de Windows en Linux con facilidad, vea el proyecto PlayOnGit:"
    )
else
    MESSAGES=(
        ["intuitive_install"]="An intuitive way to install ArchLinux"
        ["connect_internet"]="Step 01 - Connect to the Internet."
        ["check_wifi_interface"]="Check your Wifi network interface"
        ["enter_iwd_interface"]="Enter the IWD interface"
        ["type_commands_inside_interface"]="Inside the interface, type the following commands:"
        ["start_searching_network"]="To start searching the network assuming your device is 'wlan0'"
        ["list_available_networks"]="To list available networks (SSID)"
        ["finally_connecting_internet"]="Finally, connecting to the Internet"
        ["optional_step_backup"]="Optional Step - Backup - For a system reinstall without formatting"
        ["backup_can_be"]="BACKUP CAN BE, FOR A LIST."
        ["reinstall_downloading_packages"]=" - For a reinstall, downloading the packages again:"
        ["read_command_02_lines"]="Read. In the line below contains '2' command lines, obey each command:"
        ["read_command_03_lines"]="Read. In the line below contains '3' command lines, obey each command:"
        ["read_command_07_lines"]="Read. In the line below contains '7' command lines, obey each command:"
        ["reuse_existing_packages"]="OR YOU CAN REUSE EXISTING PACKAGES FROM YOUR HD WITH THIS METHOD:"
        ["first_mount_root_partition"]="First mount the root partition (/)"
        ["analyze_subvolume_interfering"]="Analyze if there is subvolume interfering:"
        ["backup_existing_packages_cache"]="Back up existing packages in the cache:"
        ["step_02_partitioning_formatting"]="Step 02 - Partitioning and Formatting:"
        ["partition_hd"]="Partition the HD"
        ["create_sda1_partition"]="Create 'sda1' 250MB to boot - If it is 'UEFI' the partition of 'BOOT' have to be in 'FAT'"
        ["create_sda2_partition"]="Create 'sda2' a partition for the root (/) of the system (root) of at least 30GB."
        ["create_sda3_partition"]="Create 'sda3' 512MB or 3GB for swap/ '3GB if you want sleep mode' - can be a larger size, up to the same number of your RAM."
        ["to_partition_use_commands"]="To partition use these commands:"
        ["to_check_existing_partitions"]="To check existing partitions:"
        ["to_zero_hd_create_partition_table"]="To quickly zero the HD and create a new partition table:"
        ["to_create_partitions_existing_table"]="To just create partitions within an existing partition table:"
        ["another_partitioner_text_mode"]="For another partitioner in text mode, very efficient by the way, in my opinion the best: 'parted'"
        ["properly_format_linux_partitions"]="To properly format each linux partition. Format in ext4 64Bits or XFS."
        ["in"]="in"
        ["or"]="Or:"
        ["else"]="Else:"
        ["example"]="Example:"
        ["ext4_compatible_desktop"]="'EXT4' and more 'compatible' with DESKTOP programs: games, etc. Not to mention that ext4 is a mature system. Which supports improper shutdown."
        ["xfs_fastest_file_system"]="On the other hand 'XFS' is the fastest file system with proper support for SSD's. Equally, it is a mature system with Journaling."
        ["for_uefi"]="For 'UEFI':"
        ["boot_partition_fat"]="The partition '/boot' or '/boot/EFI' already have to be in 'FAT-12/16/32'."
        ["fat_partition_sizes"]="It is worth noting that a partition 'FAT12' have to have at least '1M'. already the 'FAT16' with at least '9M' and 'FAT32' with at least '33M'."
        ["boot_partition_minimum"]="If you are going to use it as '/boot' have to have at least '250M' as '/boot/EFI' is the minimum indicated above corresponding to the chosen 'FAT' partition type."
        ["use_f12_fat12"]="Use '-F12' for FAT12. Example:"
        ["reduce_cluster_size"]="Use '-s2' to reduce cluster size and make the partition readable by UEFI."
        ["formatting_example"]="FORMATTING EXAMPLE:"
        ["option_L_assigns_labels"]="The option '-L' assigns labels to partitions, which helps to query them later through '/dev/disk/by-label' without having to remember your numbers. Now mount your partitions:"
        ["efi_partition_required"]="EFI partition, required for EFI systems."
        ["boot_partition_optional"]="BOOT partition, is optional, but good practice to use a separate BOOT partition in case of errors."
        ["root_part"]="ROOT partition."
        ["home_part_opt"]="HOME partition, Optional."
        ["swap_part_opt"]="SWAP partition, Optional."
        ["partition_table_assembly_example"]="PARTITION TABLE ASSEMBLY EXAMPLE, ACCORDING TO FORMATTING ABOVE:"
        ["enable_swap"]="Enable SWAP"
        ["mount_root"]="Mounting the ROOT Partition"
        ["create_home"]="Create home folder"
        ["mount_home"]="Mount HOME Partition"
        ["create_boot_efi"]="Create boot folder and EFI"
        ["mount_boot"]="Mount the BOOT Partition"
        ["mount_efi"]="Mount the EFI partition"
        ["step_03_finally_installation"]="Step 03 - FINALLY, LET'S GO TO INSTALLATION:"
        ["load_keyboard_layout_us"]="To just load the keyboard layout for US:"
        ["prepare_base_install_kernel"]="Prepare the system base and install the kernel"
        ["inside_system_chroot"]="Now it's inside the system (chroot):"
        ["encrypted_hd_instructions"]="For encrypted HDs (only if you deliberately encrypted it), follow this LINK from my tutorial:"
        ["install_grub"]="To ensure the system boots correctly, install GRUB:"
        ["for_uefi_systems"]="For UEFI systems:"
        ["boot_partition_fat_already_formatted"]="The '/boot' or '/boot/EFI' partition must already be in FAT-12/16/32 (as previously mentioned)."
        ["prepare_grub_uefi"]="Now prepare GRUB for UEFI:"
        ["efi_partition_separated_boot_efi"]="If the EFI partition is separate and mounted at '/boot/EFI':"
        ["boot_partition_fat_mounted_boot"]="Or if the entire BOOT partition is FAT and mounted at '/boot':"
        ["for_bios_i386_pc"]="For BIOS (i386-pc):"
        ["force_gpt_partition_table"]="Use '--force' if the partition table is GPT"
        ["use_automation_script"]="Use this automation script."
        ["finish_with"]="Finish with:"
        ["dual_boot_rwindows_os_prober"]="If dual-booting with Windows, install 'os-prober' and repeat the previous command (or install it beforehand):"
        ["root_password"]="Root password"
        ["create_username"]="Create your username (no accents; change 'YourPreferenceUser' to your preferred name, e.g., 'john')"
        ["create_user_password"]="Creating a password for your user:"
        ["edit_sudoers_admin_access"]="Editing SUDOers for admin access:"
        ["edit_sudoers_add_user"]="Find the line: 'root ALL=(ALL) ALL'\nBelow it, add your username: 'YourPreferenceUser ALL=(ALL) ALL'"
        ["alternative_admin_access_doas_sudo"]="You can also use 'doas' as an alternative to 'sudo'"
        ["install_xorg"]="For XORG (essential for a graphical interface):"
        ["dual_boot_windows_use"]="If dual booting with Windows, use:"
        ["set_hostname"]="Set your hostname:"
        ["for_internet_access"]="For internet access:"
        ["step_04_drivers"]="Step 04 - Drivers"
        ["enable_multilib_pacman_conf"]="Enable Multilib in '/etc/pacman.conf'\nUncomment the lines '[multilib]' and 'Include = /etc/pacman.d/mirrorlist'"
        ["for_nvidia_drivers"]="For Nvidia drivers:"
        ["for_intel_driver"]="For Intel drivers:"
        ["for_amd_drivers"]="For AMD drivers:"
        ["enable_radv_amdgpu"]="To enable Radv for your AMDGPU RADEON, follow my easy tutorial:"
        ["for_audio_driver"]="For the audio driver:"
        ["step_05_desktop"]="Step 05 - Desktop"
        ["choose_desktop_environment"]="Choose a desktop environment (KDE, Cinnamon, GNOME, Deepin, XFCE, MATE)"
        ["for_plasma_kde"]="For Plasma KDE:"
        ["install_cinnamon"]="To install Cinnamon:"
        ["install_gnome"]="To install GNOME:"
        ["install_deepin"]="To install Deepin:"
        ["install_xfce"]="To install XFCE:"
        ["install_mate"]="To install MATE:"
        ["step_06_startx"]="Step 06 - For those who prefer 'startx' over display managers (SDDM/GDM/LightDM)"
        ["tty_autologin_getty"]="For TTY autologin (without a display manager like LightDM, GDM, SDDM):"
        ["step_07_performance_games_security"]="Step 07 - Adjustments for Performance / Games / Security"
        ["prepare_games_dependencies"]="Prepare for gaming: Install necessary dependencies to significantly boost game performance."
        ["install_codecs"]="For codecs (essential for multimedia support: sound and video):"
        ["optimize_system_performance_security"]="To make your computer faster, more efficient, and more secure; improve performance and FPS in games:"
        ["adjust_limits_conf_performance"]="In '/etc/security/limits.conf' (improves performance and FPS in games):"
        ["for_notebooks"]="For notebooks:"
        ["prevent_monitor_sleep"]="To prevent your monitor from turning off or dimming (black screen):"
        ["step_08_enable_hibernation"]="Step 08 - Enable Hibernation"
        ["for_system_hibernation"]="For system hibernation (example):"
        ["hibernation_uuid_configuration"]="Configure the UUID for hibernation (see example below and use the UUID from the 'blkid' command output)."
        ["add_resume_hook_mkinitcpio"]="In '/etc/mkinitcpio.conf', add 'resume' to the 'HOOKS' array after 'filesystems'."
        ["apply_hibernation_changes"]="After making the changes, run the following commands to enable hibernation:"
        ["hibernation_swapfile_tutorial"]="If you use a swapfile for virtual memory and want to enable hibernation, follow this tutorial:"
        ["step_09_additional_apps_drivers_configs"]="Step 09 - Additional Apps, Drivers, and Configurations"
        ["install_printers"]="To install printers:"
        ["install_libreoffice"]="To install LibreOffice:"
        ["install_truetype_fonts"]="Optional: Install TrueType fonts to expand your system's font selection. Search for and install your preferred fonts."
        ["install_all_fonts_repository"]="To install all available fonts from the repository at once:"
        ["install_these_fonts"]="Or you can also install these fonts:"
        ["change_distribution_name"]="To change the name of your distribution (optional):"
        ["install_yay_for_aur"]="To use the AUR (Arch User Repository) for programs not in the official repositories, install yay:"
        ["install_windows_games_playongit"]="To easily install Windows games on Linux, see the PlayOnGit project:"
    )
fi

if [[ "${XDG_SESSION_TYPE}" != [Tt][Tt][Yy] ]]; then
    bbrown_on_beige='\033[1;38;2;139;69;19;48;2;245;222;179m'
    white_on_black='\033[38;2;255;255;255;48;2;0;0;0m'
    bgreen_on_blue='\033[1;38;2;33;252;33;48;2;8;0;242m'
    bblue_on_gray='\033[1;38;2;8;0;242;48;2;156;156;156m'
    gray='\033[1;38;2;156;156;156m'
else
    bbrown_on_beige='\033[1;38;5;130;48;5;230m'
    white_on_black='\033[38;5;15;48;5;16m'
    bgreen_on_blue='\033[1;38;5;46;48;5;32m'
    bblue_on_gray='\033[1;38;5;56;48;5;240m'
    gray='\033[1;38;5;244m'
fi
byellow_on_gray='\033[1;33;40m'
bblue_on_cyan='\033[1;46;34m'
nc='\033[0m'

function line_shell {
    echo -e "${gray}$(seq -s '━' "$(tput cols)" | tr -d '[:digit:]')"
}

function line_break {
    echo -e "\n\n"
}

function fill_background {
    local color="$1"
    local text="$2"
    local cols=$(tput cols)    # Get the width of the terminal

    # Build the line with colorful background
    printf "${color}%-*s\033[0m\n" "$cols" "$text"
}

function centralize_text {
    local color="$1"   
    local text="$2"
    local cols=$(tput cols)                        # Get the width of the terminal
    local text_len=${#text}                        # Text length
    local padding=$(( (cols - text_len) / 2 ))     # Calculate spaces to centralize

    # Build the line with colorful background and centralized text
    printf "${color}%*s%s%*s\033[0m\n" "$padding" "" "$text" "$padding" ""
}

function colorize_line_by_line() {
    while IFS= read -r line; do
        printf "${1}%s${nc}\n" "$line"
    done <<< "$(echo -e "${2}")"
}


{ # Redirects the output of the script to less

centralize_text "${bbrown_on_beige}" "${MESSAGES[intuitive_install]}"
echo -e "${white_on_black} > by Felipe Facundes${nc}"

line_break

line_shell 
fill_background "${bbrown_on_beige}" " ${MESSAGES[connect_internet]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[check_wifi_interface]}${nc}"
echo -e " $ ${bgreen_on_blue}iwconfig${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[enter_iwd_interface]}${nc}"
echo -e " $ ${bgreen_on_blue}iwctl${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[type_commands_inside_interface]}${nc}"
echo -e " $ ${bgreen_on_blue}device list${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[start_searching_network]}${nc}"
echo -e " $ ${bgreen_on_blue}station wlan0 scan${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[list_available_networks]}${nc}"
echo -e " $ ${bgreen_on_blue}station wlan0 get-networks${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[finally_connecting_internet]}${nc}"
echo -e " $ ${bgreen_on_blue}station wlan0 connect SSID${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[optional_step_backup]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[backup_can_be]}${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[reinstall_downloading_packages]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}"'pacman -Qnq | tee list.txt &>/dev/null'"${nc}"
echo -e " 2. - $ ${bgreen_on_blue}pacman -S \$(cat list.txt)${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[reuse_existing_packages]}${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[first_mount_root_partition]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}mount /dev/sdX /mnt${nc}"
echo -e " 2. - $ ${bgreen_on_blue}remove_old_system${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[analyze_subvolume_interfering]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}btrfs subvol list -a /mnt/${nc}"
echo -e " 2. - $ ${bgreen_on_blue}btrfs subvol delete /mnt/var/lib/machines${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[backup_existing_packages_cache]}${nc}"
echo -e " $ ${bgreen_on_blue}backup_existing_packages_cache${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_02_partitioning_formatting]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[partition_hd]}${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[create_sda1_partition]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[create_sda2_partition]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[create_sda3_partition]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[to_partition_use_commands]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[to_check_existing_partitions]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}blkid${nc}"
echo -e " 2. - $ ${bgreen_on_blue}fdisk -l${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[to_zero_hd_create_partition_table]}${nc}"
echo -e " $ ${bgreen_on_blue}cfdisk -z /dev/sda${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[to_create_partitions_existing_table]}${nc}"
echo -e " $ ${bgreen_on_blue}cfdisk /dev/sda${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[another_partitioner_text_mode]}${nc}"
echo -e " $ ${bgreen_on_blue}parted /dev/sda${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[properly_format_linux_partitions]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[example]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}mke2fs -text4 -O 64bit /dev/sdX${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo -e " 2. - $ ${bgreen_on_blue}mkfs.xfs /dev/sdX${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[ext4_compatible_desktop]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[xfs_fastest_file_system]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}mke2fs -text4 -O 64bit -L ROOT /dev/sdX${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo -e " 2. - $ ${bgreen_on_blue}mkfs.xfs -L ROOT /dev/sdX${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_uefi]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[boot_partition_fat]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[fat_partition_sizes]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[boot_partition_minimum]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[use_f12_fat12]}${nc}"
echo
echo -e " -  ${bblue_on_gray}${MESSAGES[reduce_cluster_size]}${nc}"
echo -e " -  $ ${bgreen_on_blue}mkfs.fat -F12 -s2 -n EFI /dev/sdX${nc}"
echo -e " -  ${bblue_on_gray}${MESSAGES[else]}${nc}"
echo -e "   -  $ ${bgreen_on_blue}mkfs.fat -F12 -n EFI /dev/sdX${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[formatting_example]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[option_L_assigns_labels]}${nc}"
echo
echo -e "
 1. - $ ${bgreen_on_blue}mkfs.fat -F12 -n EFI /dev/sda1${nc}              # <‐  ${bblue_on_gray}${MESSAGES[efi_partition_required]}${nc}
 2. - $ ${bgreen_on_blue}mke2fs -text4 -O 64bit -L BOOT /dev/sda2${nc}    # <‐  ${bblue_on_gray}${MESSAGES[boot_partition_optional]}${nc}
 3. - $ ${bgreen_on_blue}mkfs.xfs -L ROOT /dev/sda3${nc}                  # <‐  ${bblue_on_gray}${MESSAGES[root_part]}${nc}
 4. - $ ${bgreen_on_blue}mkfs.xfs -L HOME /dev/sda4${nc}                  # <‐  ${bblue_on_gray}${MESSAGES[home_part_opt]}${nc}
 5. - $ ${bgreen_on_blue}mkswap -L SWAP /dev/sda5${nc}                    # <‐  ${bblue_on_gray}${MESSAGES[swap_part_opt]}${nc} 
"

echo

echo -e " ${bblue_on_gray}${MESSAGES[partition_table_assembly_example]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_07_lines]}${nc}"

echo -e "
 1. - $ ${bgreen_on_blue}swapon /dev/sda5${nc}                # <-  ${bblue_on_gray}${MESSAGES[enable_swap]}${nc} 
 2. - $ ${bgreen_on_blue}mount /dev/sda3 /mnt${nc}            # <-  ${bblue_on_gray}${MESSAGES[mount_root]}${nc} 
 3. - $ ${bgreen_on_blue}mkdir -p /mnt/home${nc}              # <-  ${bblue_on_gray}${MESSAGES[create_home]}${nc} 
 4. - $ ${bgreen_on_blue}mount /dev/sda4 /mnt/home${nc}       # <-  ${bblue_on_gray}${MESSAGES[mount_home]}${nc}  
 5. - $ ${bgreen_on_blue}mkdir -p /mnt/boot/EFI${nc}          # <-  ${bblue_on_gray}${MESSAGES[create_boot_efi]}${nc}
 6. - $ ${bgreen_on_blue}mount /dev/sda2 /mnt/boot${nc}       # <-  ${bblue_on_gray}${MESSAGES[mount_boot]}${nc}
 7. - $ ${bgreen_on_blue}mount /dev/sda1 /mnt/boot/EFI${nc}   # <-  ${bblue_on_gray}${MESSAGES[mount_efi]}${nc}
"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_03_finally_installation]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[load_keyboard_layout_us]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e "
 1. - $ ${bgreen_on_blue}loadkeys us${nc}
 2. - $ ${bgreen_on_blue}export LANG=en_US.UTF-8${nc}
"

echo

echo -e " ${bblue_on_gray}${MESSAGES[prepare_base_install_kernel]}${nc}" 
echo -e " $ ${bgreen_on_blue}pacstrap_base_install${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[inside_system_chroot]}${nc}" 
echo -e " $ ${bgreen_on_blue}arch-chroot /mnt${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[encrypted_hd_instructions]}${nc}" 
echo -e " ${bblue_on_cyan}https://github.com/felipefacundes/desktop/tree/master/GRUB${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_grub]}${nc}"
echo -e " $ ${bgreen_on_blue}grub_prepare${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_uefi_systems]}${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[boot_partition_fat_already_formatted]}${nc}"
echo -e " $ ${bgreen_on_blue}mkfs.fat -F12 -n EFI /dev/sdX${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[prepare_grub_uefi]}${nc}"
echo -e " $ ${bgreen_on_blue}grub_install.sh efi${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo
echo -e " -  ${bblue_on_gray}${MESSAGES[efi_partition_separated_boot_efi]}${nc}"
echo -e " $ ${bgreen_on_blue}grub-install --verbose --recheck --target=x86_64-efi --force --efi-directory=/boot/EFI --bootloader-id=ARCH --removable${nc}"
echo -e " -  ${bblue_on_gray}${MESSAGES[boot_partition_fat_mounted_boot]}${nc}"
echo -e " $ ${bgreen_on_blue}grub-install --verbose --recheck --target=x86_64-efi --force --efi-directory=/boot --bootloader-id=ARCH --removable${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_bios_i386_pc]}${nc}"
echo -e " $ ${bgreen_on_blue}grub_install.sh i386 /dev/sdX${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo
echo -e " -  ${bblue_on_gray}${MESSAGES[force_gpt_partition_table]}${nc}"
echo -e " $ ${bgreen_on_blue}grub-install --verbose --recheck --target=i386-pc --force /dev/sdX${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[finish_with]}${nc}"
echo -e " $ ${bgreen_on_blue}grub-mkconfig -o /boot/grub/grub.cfg${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[dual_boot_rwindows_os_prober]}${nc}"
echo -e " $ ${bgreen_on_blue}pacman -S os-prober${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[root_password]}${nc}"
echo -e " $ ${bgreen_on_blue}passwd root${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[create_username]}${nc}"
echo -e " $ ${bgreen_on_blue}create_new_user${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}useradd -m -g users -G daemon,disk,wheel,rfkill,dbus,network,video,audio,storage,power,users,input -s /bin/bash YourPreferenceUser${nc}"
echo
echo -e " 2. - $ ${bgreen_on_blue}usermod -a -G daemon,disk,wheel,rfkill,dbus,network,video,audio,storage,power,users,input YourPreferenceUser${nc}"
echo

line_break

echo -e " ${bblue_on_gray}${MESSAGES[create_user_password]}${nc}"
echo -e " $ ${bgreen_on_blue}passwd YourPreferenceUser${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[edit_sudoers_admin_access]}${nc}"
echo -e " $ ${bgreen_on_blue}sudoers_config${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo
echo -e " $ ${bgreen_on_blue}visudo /etc/sudoers${nc}"
echo
colorize_line_by_line " ${bblue_on_gray}" "${MESSAGES[edit_sudoers_add_user]}"
echo -e "
 ${white_on_black}# ...${nc}
 ${white_on_black}root ALL=(ALL) ALL${nc}
 ${white_on_black}YourPreferenceUser ALL=(ALL) ALL${nc}
"

echo

echo -e " ${bblue_on_gray}${MESSAGES[alternative_admin_access_doas_sudo]}${nc}"
echo -e " $ ${bgreen_on_blue}doas_config${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_xorg]}${nc}"
echo -e " $ ${bgreen_on_blue}xorg_install.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[dual_boot_windows_use]}${nc}"
echo -e " $ ${bgreen_on_blue}fix-dualboot-time.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo
echo -e " ${bblue_on_cyan}https://wiki.archlinux.org/title/System_time#UTC_in_Microsoft_Windows${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[set_hostname]}${nc}"
echo -e " $ ${bgreen_on_blue}echo ArchLinux | tee /etc/hostname${nc}"
echo -e " $ ${bgreen_on_blue}hostnamectl set-hostname ArchLinux${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_internet_access]}${nc}"
echo -e " $ ${bgreen_on_blue}networkmanager_install.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_04_drivers]}"
line_shell

line_break

colorize_line_by_line " ${bblue_on_gray}" "${MESSAGES[enable_multilib_pacman_conf]}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo -e " $ ${bgreen_on_blue}enable_multilib_pacman_conf.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_nvidia_drivers]}${nc}"
echo -e " $ ${bgreen_on_blue}video_drivers_install.sh nvidia${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_intel_driver]}${nc}"
echo -e " $ ${bgreen_on_blue}video_drivers_install.sh intel${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_amd_drivers]}${nc}"
echo -e " $ ${bgreen_on_blue}video_drivers_install.sh amd${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo
echo -e " ${bblue_on_gray}${MESSAGES[enable_radv_amdgpu]}${nc}"
echo -e " ${bblue_on_cyan}https://amdgpu.github.io/${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_audio_driver]}${nc}"
echo -e " $ ${bgreen_on_blue}audio_drivers_install.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_05_desktop]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[choose_desktop_environment]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_plasma_kde]}${nc}"
echo -e " $ ${bgreen_on_blue}desktop_install.sh kde${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_cinnamon]}${nc}"
echo -e " $ ${bgreen_on_blue}desktop_install.sh cinnamon${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_gnome]}${nc}"
echo -e " $ ${bgreen_on_blue}desktop_install.sh gnome${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_deepin]}${nc}"
echo -e " $ ${bgreen_on_blue}desktop_install.sh deepin${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_xfce]}${nc}"
echo -e " $ ${bgreen_on_blue}desktop_install.sh xfce${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_mate]}${nc}"
echo -e " $ ${bgreen_on_blue}desktop_install.sh mate${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_06_startx]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[tty_autologin_getty]}${nc}"
echo -e " $ ${bgreen_on_blue}getty_autologin${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

### Start SERVICE
#'systemctl enable getty@.service'

#line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_07_performance_games_security]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[prepare_games_dependencies]}${nc}"
echo -e " $ ${bgreen_on_blue}prepare_games_dependencies${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_codecs]}${nc}"
echo -e " $ ${bgreen_on_blue}install_codecs.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[optimize_system_performance_security]}${nc}"
echo -e " $ ${bgreen_on_blue}sysctl_config${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[adjust_limits_conf_performance]}${nc}"
echo -e " $ ${bgreen_on_blue}security_limits_conf${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_notebooks]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}pacman -S xf86-input-synaptics acpi libinput${nc}"
echo -e " 2. - $ ${bgreen_on_blue}echo 'vm.laptop_mode=1' | tee -a /etc/sysctl.conf${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[prevent_monitor_sleep]}${nc}"
echo -e " $ ${bgreen_on_blue}xorg_no_sleep_config.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_08_enable_hibernation]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[for_system_hibernation]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}blkid${nc}"
echo -e " 2. - $ ${bgreen_on_blue}nano /etc/default/grub${nc}"

echo

echo -e " ${bblue_on_gray}${MESSAGES[hibernation_uuid_configuration]}${nc}"
echo -e " ${white_on_black}resume=UUID=\"swap UUID\" ${MESSAGES[in]} \"GRUB_CMDLINE_LINUX_DEFAULT=\"${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[add_resume_hook_mkinitcpio]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[apply_hibernation_changes]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}grub-mkconfig -o /boot/grub/grub.cfg${nc}"
echo -e " 2. - $ ${bgreen_on_blue}mkinitcpio -P${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[hibernation_swapfile_tutorial]}${nc}"
echo -e " ${bblue_on_cyan}https://github.com/felipefacundes/desktop/tree/master/swapfile-hibernate${nc}"

line_break

line_shell
fill_background "${bbrown_on_beige}" " ${MESSAGES[step_09_additional_apps_drivers_configs]}"
line_shell

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_printers]}${nc}"
echo -e " $ ${bgreen_on_blue}install_printers.sh${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_libreoffice]}${nc}"
echo -e " $ ${bgreen_on_blue}pacman -S libcdr libreoffice-fresh${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_truetype_fonts]}${nc}"
echo -e " $ ${bgreen_on_blue}pacman -Ss ttf${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_all_fonts_repository]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_02_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}pacman -S \$(pacman -Ssq ttf)${nc}"
echo -e " 2. - $ ${bgreen_on_blue}fc-cache${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_these_fonts]}${nc}"
echo -e " $ ${bgreen_on_blue}install_these_ttf_fonts minimum${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo -e " $ ${bgreen_on_blue}install_these_ttf_fonts maximum${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[change_distribution_name]}${nc}"
echo -e " $ ${bgreen_on_blue}arch_lsb_release${nc}  ${byellow_on_gray} <‐ ${MESSAGES[use_automation_script]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[or]}${nc}"
echo -e " 1. - $ ${bgreen_on_blue}pacman -S lsb-release${nc}"
echo -e " 2. - $ ${bgreen_on_blue}nano /etc/lsb-release${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_yay_for_aur]}${nc}"
echo -e " ${bblue_on_gray}${MESSAGES[read_command_03_lines]}${nc}"
echo
echo -e " 1. - $ ${bgreen_on_blue}git clone https://aur.archlinux.org/yay.git${nc}"
echo -e " 2. - $ ${bgreen_on_blue}cd yay${nc}"
echo -e " 3. - $ ${bgreen_on_blue}makepkg -si${nc}"

line_break

echo -e " ${bblue_on_gray}${MESSAGES[install_windows_games_playongit]}${nc}"
echo -e " - ${bblue_on_cyan}https://www.github.com/felipefacundes/PlayOnGit/${nc}"
echo -e " - ${bblue_on_cyan}https://jogoslinux.github.io/${nc}"

line_break

} | less -R -i