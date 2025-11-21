##### Criando um Pendrive Multiboot no ArchLinux, com Ferramentas administrativas, diversas distrinuições Linux e com Windows.
<br/>
<br/>

###### Iremos usar tanto o sistema UEFI para BOOT como MBR (para sistemas mais antigos).

----

###### Primeiro formate o pendrive com uma partição pequena de `40M` como `FAT32`, para usar como `EFI`. A tabela de partição não precisa ser em GPT, usaremos a tabela `DOS`, a tabela GPT é superior a tabela DOS - principalmente pelo tamanho, na GPT pode se ter partições de 9,4ZB e na DOS é somente até 2T. Porém, com a tabela GPT o GRUB não escreve no MBR.

----

##### Instale algumas Ferramentas no seu sistema, antes de gerir o pendrive:
`sudo pacman -S arch-install-scripts exfatprogs mtools dosfstools libisoburn`

----

##### Detectando qual unidade é o pendrive:
`sudo fdisk -l`

----

##### Criando a tabela de partição no pendrive:
`sudo cfdisk -z /dev/sdX` # Onde X é a letra que corresponde ao seu pendrive.

----

###### Ao escolher a tabela DOS crie a primeira partição de `40M` a segunda com o tamanho inteiro, e se quiser ter o Instalador do Windows no pendrive basta, criar uma terceira partição como `FAT32`, porém, esta partição tem que ser no tamanho exato da imagem ISO, exemplo, para uma imagem do Windows 8.1, essa partição precisará ter 4,5G.

----

###### Não crie mais que três partições, pois a partir da 4ª partição o pendrive ficará lento. Então, só crie 3 partições. A primeira use como `FAT32`/EFI. A segunda, será a maior partição como `EXT4` e a terceira para Windows Installer como `FAT32`.

----

##### Supondo que o seu pendrive seja a segunda unidade de disco com a letra `B`, lembrando, antes detecte a unidade com `sudo fdisk -l`. Então, formate assim:
```
sudo mkfs.vfat -F32 -n EFI /dev/sdX1
sudo mkfs.ext4 /dev/sdX2
sudo mkfs.vfat -F32 -n WIN_INSTALL /dev/sdX3
```

----

##### Montando às unidades - substitua a letra `B` pela letra correspondente do seu pendrive:
```
sudo mount /dev/sdX2 /mnt
sudo mkdir -p /mnt/boot/EFI
sudo mkdir -p /mnt/WIN_INSTALL
sudo mkdir -p /mnt/ISOs
sudo mount /dev/sdX1 /mnt/boot/EFI
sudo mount /dev/sdX3 /mnt/WIN_INSTALL
sudo chown -R "$USER":users /mnt/
```

----

##### Instale o básico no pendrive, NÂO instale o kernel
`sudo pacstrap -i /mnt coreutils efibootmgr exfatprogs grub dosfstools libisoburn mtools sed`

----

###### Baixe às imagems ISO que deseja que o pendrive tenha no BOOT.

----

###### Para Windows, faça o seguinte:
```
mkdir ~/WIN
sudo modprobe loop
sudo mount -o loop Instalador-do-Windows.iso ~/WIN

cp -rf ~/WIN/* /mnt/WIN_INSTALL/ && sync

sudo umount -R ~/WIN && rm -rf ~/WIN
```

----

###### Se você você for ter uma imagem de alguma distribuição Linux no pendrive, copie no pendrive na pasta ISOs.
`cp -f imagem-da-distribuição-linux.iso /mnt/ISOs/`

----

###### Editando o `40_custom` do GRUB para ter múltiplos boots no pendrive. Use o editor de texto da sua preferência, no exemplo aqui será o `vim`

`sudo vim /mnt/etc/grub.d/40_custom`

----

##### Exemplo de `40_custom` com o Instalador do Windows na partição do pendrive e ArchLinux ISO, lembrando que você poderá ter qualquer distribuição Linux no pendrive, mas para cada distribuição Linux os parâmetros da ISO são diferentes:

###### Antes de tudo verifique o UUID de cada partição do pendrive com o comando: `sudo blkid` e substitua onde está `1234-5678` pelo UUID correspondente da partição onde estão às ISOs e a partição do Windows Installer.
```markdown
menuentry "Recovery: ArchLinux-2022.03.iso" --hotkey=0 --class dvd {
      	insmod part_gpt
      	insmod search_fs_uuid
      	set root=UUID=d3c602bf-4a10-4948-b4c4-13f7d3fa0bc2
      	set isofile="/archlinux-2022.03.01-x86_64.iso"
      	set dri="free"
      	search --no-floppy -f --set=root $isofile
      	probe -u $root --set=abc
      	set pqr="/dev/disk/by-uuid/$abc"
      	loopback loop $isofile
      	linux (loop)/arch/boot/x86_64/vmlinuz-linux img_dev=$pqr img_loop=$isofile driver=$dri
      	initrd (loop)/arch/boot/intel-ucode.img (loop)/arch/boot/amd-ucode.img (loop)/arch/boot/x86_64/initramfs-linux.img
}

menuentry "ArchLinux-2020.iso" --class dvd {
      insmod part_msdos
      insmod search_fs_uuid
      set root=UUID=1234-5678
      set isofile="/ISOs/ArchLinux-2020.iso" root=UUID=1234-5678
      set dri="free"
      search --no-floppy -f --set=root $isofile
      probe -u $root --set=abc
      set pqr="/dev/disk/by-uuid/$abc"
      loopback loop $isofile
      linux (loop)/arch/boot/x86_64/vmlinuz img_dev=$pqr img_loop=$isofile driver=$dri
      initrd (loop)/arch/boot/x86_64/archiso.img
}

menuentry "Windows 10 Installer Partition" --class windows --class os {
        insmod part_msdos
        insmod chain
        insmod exfat
        insmod fat
        insmod search_fs_uuid
        set root=UUID=1234-5678
        search --no-floppy --fs-uuid --set=root 1234-5678
        chainloader /efi/boot/bootx64.efi root=UUID=1234-5678
}

menuentry "Android (Phoenix-OS)" --hotkey=a --class android-x86 {
	insmod part_gpt
	insmod search_fs_uuid
	set root=UUID=5cbd2559-e23e-4696-9645-08580d8e3fb7
	search --file --no-floppy --set=root /PhoenixOS/system.img
        linux /PhoenixOS/kernel root=/dev/ram0 androidboot.hardware=android_x86_64 androidboot.selinux=permissive quiet SRC=/PhoenixOS Data=/data vga=788
	initrd /PhoenixOS/initrd.img
}

menuentry "Android (BlissOS-v11.13)" --hotkey=1 --class android-x86 {
	insmod part_gpt
	insmod search_fs_uuid
	set root=UUID=5cbd2559-e23e-4696-9645-08580d8e3fb7
	search --file --no-floppy --set=root /BlissOS-v11.13/system.img
        linux /BlissOS-v11.13/kernel root=/dev/ram0 androidboot.hardware=android_x86_64 androidboot.selinux=permissive quiet SRC=/BlissOS-v11.13 Data=/data vga=788
	initrd /BlissOS-v11.13/initrd.img
}
```

----

##### Após às devidas modificações no arquivo `40_custom` - lembrando que você deve alterar conforme o seu caso - entre no Pendrive e faça a atualização do GRUB:
##### Agora entre no mini sistema arch e vamos gerir o GRUB:
```
sudo arch-chroot /mnt

grub-install --target=i386-pc --recheck /dev/sdX   #Este comando é para instalar o GRUB na MBR

grub-install --verbose --recheck --force --target=x86_64-efi --efi-directory=/boot/EFI --bootloader-id=MULTIBOOT --removable

grub-mkconfig -o /boot/grub/grub.cfg

exit    #Ou control + D - para sair do chroot

sudo umount -R /mnt
```

----

##### Pendrive pronto, basta reiniciar o sistema e dar boot pelo pendrive. Não esqueça de ler esse artigo com cautela para fazer tudo certinho ;)

----

###### Segue alguns exemplos de `40_custom`:
[Exemplo 1](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom_2022)

[Exemplo 2](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom)

[Exemplo 3](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom.example.2)

[Exemplo 4](https://github.com/felipefacundes/MultiBoot/blob/main/examples/40_custom.example.several)
