#!/usr/bin/env bash
# License: GPLv3
# Credits: Felipe Facundes

: <<'DOCUMENTATION'
Script Name: pacman-pkg-backup.sh

This Bash script is designed to generate a PKGBUILD file from an already installed package in an Arch Linux environment. 
Its main purpose is to facilitate the creation of a PKGBUILD, which is essential for building packages from source. 

Strengths:
1. User -Friendly Help Message: Provides clear instructions on usage and requirements when invoked without arguments or with help flags.
2. Package Validation: Checks if the specified package is installed before proceeding, ensuring that only valid packages are processed.
3. Automated Information Retrieval: Extracts essential package details such as version, architecture, dependencies, and description automatically.
4. Dynamic PKGBUILD Creation: Generates a complete PKGBUILD file with all necessary fields populated based on the installed package's information.
5. Post-Creation Option: Offers the user the choice to immediately build the package using 'makepkg -s' after creating the PKGBUILD.

Capabilities:
- Validates package installation status.
- Retrieves and formats package metadata.
- Creates a structured PKGBUILD file.
- Handles symbolic links and file permissions appropriately during the package creation process.
DOCUMENTATION

# Package name
pkgname=$1

if [[ -z "$pkgname" || "$pkgname" == '-h' || "$pkgname" == '--help' ]]; then
  cat << EOF
  To generate a PKGBUILD from an already installed package.
  Make backups of your already installed packages.
  
  Usage: ${0##*/} <package name>

  After generating PKGBUILD, enter the generated folder and run the command: makepkg -s
EOF
  exit 1
fi

# Check if the package is installed
if pacman -Qs "$pkgname" > /dev/null ; then
    echo "Package $pkgname is installed."
else
    echo "Package $pkgname is not installed."
    exit 1
fi

# Retrieve package information
pkginfo=$(LC_ALL=c pacman -Qi $pkgname)

# Extract version, architecture and dependencies
pkgver=$(echo "$pkginfo" | grep Version | cut -d: -f2 | tr -d ' ' | cut -d- -f1)
pkgrel=$(echo "$pkginfo" | grep Version | cut -d: -f2 | tr -d ' ' | cut -d- -f2)
arch=$(echo "$pkginfo" | grep Architecture | cut -d: -f2 | tr -d ' ')
url=$(echo "$pkginfo" | awk -F ": " '/URL/ {print $2}')
pkgdesc=$(echo "$pkginfo" | grep Description | cut -d: -f2)
license=$(echo "$pkginfo" | grep Licenses | cut -d: -f2)

if ! echo "$pkginfo" | grep Depends | cut -d: -f2 | grep None >/dev/null; then
    mapfile -t depends < <(echo "$pkginfo" | grep Depends | cut -d: -f2 | awk '{gsub(/ /, "\n")}1' | sed 's/^/"/;s/$/"/' | grep -v '""' | grep -v ^$)
fi

if ! echo "$pkginfo" | grep 'Optional Deps' | cut -d: -f2 | grep None >/dev/null; then
    mapfile -t optdepends < <(echo "$pkginfo" | awk '!/Name/ && !/Version/ && !/Description/ && !/Architecture/ && !/URL/ && !/Licenses/ && !/Groups/ && !/Provides/ && !/Depends On/ && !/Required By/ && !/Optional For/ && !/Conflicts With/ && !/Replaces/ && !/Install/ && !/Packager/ && !/Build Date/ && !/Validated By/ {gsub(/\[installed\]/, ""); gsub(/Optional Deps   : /, ""); gsub(/                  /, ""); if ($0 != "") print "\"" $0 "\""}')
fi

# Create a directory for PKGBUILD
mkdir -p "$pkgname" && cd "$pkgname"

# Create PKGBUILD
cat <<EOF > PKGBUILD
pkgname=$pkgname
pkgver=$pkgver
pkgrel=$pkgrel
epoch=
pkgdesc="$pkgdesc"
arch=($arch)
url="$url"
license=($license)
groups=()
depends=(${depends[@]})
makedepends=()
checkdepends=()
optdepends=(${optdepends[@]})
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=
changelog=
source=()
noextract=()
md5sums=()
validpgpkeys=()

package() {
    cd "\$srcdir"
    for file in \$(pacman -Ql $pkgname | awk '{print \$2}'); do
        if [ -e \$file ]; then
            if [ -L \$file ]; then
                # If the file is a symbolic link, copy the link
                cp -d --no-preserve=mode --parents \$file "\$pkgdir"
            elif [ -f \$file ]; then
                install -Dm644 \$file "\$pkgdir"/\$file
                # If the file is a binary in /usr/bin, change its permissions to 755
                if [[ -x \$file ]]; then
                    chmod 755 "\$pkgdir"/\$file
                fi
            elif [ -d \$file ]; then
                # If the file is a directory, create it
                install -d "\$pkgdir"/\$file
            fi
        fi
    done
    # Adjust to ensure symbolic links are handled correctly
    for link in \$(find "\$pkgdir" -type l); do
        target=\$(readlink "\$link")
        if [ -e "\$pkgdir/\$target" ]; then
            ln -sf "\$target" "\$link"
        fi
    done
}
EOF

dir=$(pwd)
echo -e "\nPKGBUILD created for package $pkgname in directory $dir.\n"

echo 'Do you want to run makepkg -s to generate the package now? [y/n]'
declare -l option
read -r option

[[ "$option" == y ]] && makepkg -s
