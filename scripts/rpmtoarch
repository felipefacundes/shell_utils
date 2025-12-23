#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
This Bash script is designed to facilitate the management of RPM packages by automating the creation 
of a directory structure and necessary files for building packages. Its primary purpose is to streamline 
the process of preparing RPM files for installation on systems that utilize the RPM Package Manager.

Strengths:
1. Dependency Check: Verifies if the 'rpm' command is available on the system before proceeding.
2. File Validation: Ensures that the provided file is a valid RPM file.
3. Dynamic Directory Creation: Automatically generates a directory based on the RPM package name.
4. PKGBUILD Generation: Creates a 'PKGBUILD' file with essential metadata for the package.
5. Script Extraction: Extracts installation scripts from the RPM and organizes them into a structured format.

Capabilities:
- Validates the presence of required tools and the integrity of the RPM file.
- Constructs a directory and copies the RPM file into it.
- Generates a 'PKGBUILD' file with customizable fields.
- Parses and organizes installation scripts for easy access and modification.
DOCUMENTATION

rpm_org_is_installed() {
    if ! command -v rpm >/dev/null 2>&1; then
        echo "The rpm-tools or rpm-org is not available on the system."
        exit 1
    fi
}

check_file_rpm() {
    local rpm_file=$(basename "$1")
    local file_type=$(type "$rpm_file" >/dev/null 2>&1)

    if [[ ! -f "$rpm_file" ]] && [[ ! "$file_type" =~ "application/x-rpm" ]]; then
        echo 'This is not a .rpm file!'
        exit 1
    fi
}

package_name() {
    local rpm_basename=$(basename "$1")
    local FILTERED_PARTS=("rpm" "x86_64")
    local result=""
    
    IFS='.' read -ra parts <<< "$rpm_basename"
    for part in "${parts[@]}"; do
        if [[ ! " ${FILTERED_PARTS[@]} " =~ " $part " ]]; then
            result+="${part}_"
        fi
    done

    echo "${result%_}"
}

create_dir() {
    local dir_name=$(package_name "$1")
    if [ ! -d "$dir_name" ]; then
        mkdir "$dir_name"
    fi
}

copy_rpm_file() {
    local rpm_basename=$(basename "$1")
    local dir_name=$(package_name "$1")
    cp "$rpm_basename" "$dir_name/"
}

create_pkgbuild() {
    local dir_name=$(package_name "$1")
    local pkgbuild_file="${dir_name}/PKGBUILD"
    
    cat <<EOF > "$pkgbuild_file"
pkgname=$(package_name "$1")
pkgver=unknown
pkgrel=1
epoch=
pkgdesc=""
arch=("x86_64")
url=""
license=('Unknown')
groups=()
depends=()
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install="$(package_name "$1").install"
changelog=
source=()
noextract=()
md5sums=()
validpgpkeys=()

prepare() {
    cp "../$(basename "$1")" "\$srcdir/"
}

package() {
    rpm2cpio "$(basename "$1")" | cpio -idmv -D "\$pkgdir/"
}
EOF
}

extract_scripts() {
    local dir_name=$(package_name "$1")
    pushd "$dir_name" >/dev/null || return
    local rpm_scripts=$(rpm -qp --scripts "$(basename "$1")" | iconv -f UTF-8 -t UTF-8 -c)
    popd >/dev/null || return
    parse_blocks "$rpm_scripts"
}

parse_blocks() {
    local rpm_scripts="$1"
    local current_block=""
    local section=""
    
    while IFS= read -r line; do
        section=$(find_section_in_line "$line")
        if [ -n "$section" ]; then
            current_block=""
        elif [ -n "$current_block" ]; then
            current_block+="$line"$'\n'
        fi
        if [ -n "$section" ] && [ -n "$current_block" ]; then
            blocks["$section"]=$current_block
        fi
    done <<< "$rpm_scripts"
}

find_section_in_line() {
    local line="$1"
    local RPM_INSTALL_SECTIONS=("preinstall" "postinstall" "preupgrade" "postupgrade" "preuninstall" "postuninstall")
    local INSTALL_SECTIONS=("pre_install" "post_install" "pre_upgrade" "post_upgrade" "pre_remove" "post_remove")
    
    for ((idx=0; idx<${#RPM_INSTALL_SECTIONS[@]}; idx++)); do
        if [[ "$line" =~ ${RPM_INSTALL_SECTIONS[$idx]} ]]; then
            echo "${INSTALL_SECTIONS[$idx]}"
            break
        fi
    done
}

create_install_script() {
    local dir_name=$(package_name "$1")
    local install_script_path="${dir_name}/$(package_name "$1").install"
    local scripts=()
    
    parse_blocks "$(extract_scripts "$1")"
    
    for section in "${!blocks[@]}"; do
        local function_name="$section"
        local code="${blocks[$section]}"
        scripts+=("$function_name() {")
        scripts+=("$code")
        scripts+=("}")
    done
    
    printf "%s\n" "${scripts[@]}" > "$install_script_path"
}

main() {
    local rpm="$1"
    local blocks=()
    
    rpm_org_is_installed
    check_file_rpm "$rpm"
    create_dir "$rpm"
    copy_rpm_file "$rpm"
    create_pkgbuild "$rpm"
    create_install_script "$rpm"
    
    local rpm_basename=$(basename "$rpm")
    local dir_name=$(package_name "$rpm")
    
    echo "Basename: $rpm_basename"
    echo "Package_name: $dir_name"
    echo "RUN: $dir_name"
}

main "$1"
