#!/bin/bash
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This script installs the necessary packages for GPU support on Arch Linux.
DOCUMENTATION

declare -A MESSAGES

if [[ "${LANG,,}" =~ pt_ ]]; then

    MESSAGES=(
        ["usage"]="Uso: ${0##*/} [opção]"
        ["description"]="Este script instala os pacotes necessários para suporte a GPU no Arch Linux."
        ["options"]="Opções:"
        ["intel"]="  intel    Instala pacotes para suporte a GPU Intel."
        ["nvidia"]="  nvidia   Instala pacotes para suporte a GPU NVIDIA."
        ["amd"]="  amd      Instala pacotes para suporte a GPU AMD."
        ["examples"]="Exemplos:"
        ["example_intel"]="  ${0##*/} intel   # Instala pacotes para GPU Intel"
        ["example_nvidia"]="  ${0##*/} nvidia  # Instala pacotes para GPU NVIDIA"
        ["example_amd"]="  ${0##*/} amd     # Instala pacotes para GPU AMD"
        ["note"]="Nota: Este script requer privilégios sudo para instalar pacotes."
        ["permissions"]="Certifique-se de ter as permissões necessárias para executá-lo."
        ["credits"]="Créditos: Felipe Facundes"
    )

else
    MESSAGES=(
        ["usage"]="Usage: ${0##*/} [option]"
        ["description"]="This script installs the necessary packages for GPU support on Arch Linux."
        ["options"]="Options:"
        ["intel"]="  intel    Install packages for Intel GPU support."
        ["nvidia"]="  nvidia   Install packages for NVIDIA GPU support."
        ["amd"]="  amd      Install packages for AMD GPU support."
        ["examples"]="Examples:"
        ["example_intel"]="  ${0##*/} intel   # Install Intel GPU packages"
        ["example_nvidia"]="  ${0##*/} nvidia  # Install NVIDIA GPU packages"
        ["example_amd"]="  ${0##*/} amd     # Install AMD GPU packages"
        ["note"]="Note: This script requires sudo privileges to install packages."
        ["permissions"]="Make sure you have the necessary permissions to run it."
        ["credits"]="Credits: Felipe Facundes"
    )

fi


function help {
    echo "${MESSAGES[usage]}"
    echo ""
    echo "${MESSAGES[description]}"
    echo ""
    echo "${MESSAGES[options]}"
    echo "${MESSAGES[intel]}"
    echo "${MESSAGES[nvidia]}"
    echo "${MESSAGES[amd]}"
    echo ""
    echo "${MESSAGES[examples]}"
    echo "${MESSAGES[example_intel]}"
    echo "${MESSAGES[example_nvidia]}"
    echo "${MESSAGES[example_amd]}"
    echo ""
    echo "${MESSAGES[note]}"
    echo "${MESSAGES[permissions]}"
    echo ""
    echo "${MESSAGES[credits]}"
}

case "$1" in
    intel)
        sudo pacman -Syy lib32-vulkan-intel lib32-mesa lib32-libva-intel-driver libva-utils intel-opencl-clang intel-media-driver intel-graphics-compiler lib32-libglvnd libglvnd linux-headers dkms intel-gpu-tools intel-gmmlib intel-compute-runtime xf86-video-intel vulkan-intel mesa libva-intel-driver iucode-tool intel-ucode intel-tbb libmfx libvpl nvtop onetbb lib32-vulkan-icd-loader vulkan-icd-loader lib32-vulkan-mesa-layers vulkan-mesa-layers lib32-vulkan-validation-layers vulkan-validation-layers spirv-tools vulkan-headers vulkan-tools vulkan-utility-libraries vkmark
    ;;

    nvidia)
        sudo pacman -Syy nvidia egl-gbm egl-wayland egl-x11 dkms nvidia-settings lib32-libvdpau lib32-libglvnd libglvnd libvdpau nvidia-utils opencl-nvidia xsettingsd xsettings-client ffnvcodec-headers libxnvctrl xf86-video-nouveau lib32-nvidia-utils lib32-opencl-nvidia nccl nvidia-cg-toolkit lib32-nvidia-cg-toolkit libnvidia-container libva-nvidia-driver nvtop onetbb intel-tbb lib32-vulkan-icd-loader vulkan-icd-loader lib32-vulkan-mesa-layers vulkan-mesa-layers lib32-vulkan-validation-layers vulkan-validation-layers spirv-tools vulkan-headers vulkan-tools vulkan-utility-libraries vkmark
    ;;

    amd)
        sudo pacman -Syy rocm-opencl-runtime rocm-clang-ocl xf86-video-amdgpu xf86-video-ati linux-headers dkms lib32-libglvnd libglvnd vulkan-radeon lib32-vulkan-icd-loader vulkan-icd-loader lib32-vulkan-validation-layers vulkan-validation-layers lib32-vulkan-mesa-layers vulkan-mesa-layers spirv-tools vulkan-headers vulkan-tools vulkan-utility-libraries vkmark
    ;;
    *)
        help
    ;;
esac