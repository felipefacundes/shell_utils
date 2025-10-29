# 📦 Pasos para Agregar un PKGBUILD al AUR

¡Bienvenido! Esta guía detalla cómo agregar un **PKGBUILD** al **Arch User Repository (AUR)** de manera sencilla y efectiva. Sigue los pasos a continuación para crear, probar y enviar tu paquete con éxito.

---

## 1️⃣ Crear una Cuenta en AUR
Ve a [aur.archlinux.org](https://aur.archlinux.org) y crea una cuenta si aún no tienes una.

### 📌 Requisitos previos:
- Un **correo electrónico válido**.
- Una **clave SSH** para interactuar con AUR a través de Git.

---

## 2️⃣ Configurar tu Clave SSH
Si aún no tienes una clave SSH, genérala con el siguiente comando:

```bash
ssh-keygen -t ed25519 -C "tu-correo@example.com"
```

### 🔑 Agregar la clave pública a AUR:
1. Copia el contenido de `~/.ssh/id_ed25519.pub`.
2. Ve a **"My Account"** en el sitio web de AUR.
3. Pega la clave en **"SSH Public Key"**.

---

## 3️⃣ Clonar el Repositorio AUR para el Paquete
Cada paquete en AUR tiene su propio repositorio Git. Como **tu_paquete** es nuevo, crearás un repositorio vacío:

```bash
git clone ssh://aur@aur.archlinux.org/tu_paquete.git

Ou:

git clone https://aur.archlinux.org/tu_paquete.git
```

📌 **Nota:** Si el paquete aún no existe, AUR permitirá su creación en el primer `push`.

---

## 4️⃣ Agregar el PKGBUILD al Repositorio
Ingresa al directorio clonado:

```bash
cd tu_paquete
```

Copia el **PKGBUILD** a este directorio. Ejemplo:

```bash
# Maintainer: Felipe Facundes <felipefacundes@example.com> # Usa tu correo real

pkgname=tu_paquete
pkgver=0.1  # Ejemplo inicial, se actualizará automáticamente
pkgrel=1
pkgdesc="Descripción para tu paquete"
arch=('i686' 'x86_64')
url="http://github.com/tu_nombre/tu_repo/"
license=('GPL')
depends=('python' 'bash' 'etc')
makedepends=('git' 'boost')
source=("git+${url}.git")
md5sums=('SKIP')

pkgver() {
  cd "${srcdir}/tu_paquete/src" || true
  echo "r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)"
}

build() {
  cd "${srcdir}/tu_paquete/src/"
  autoconf
  ./configure
  make
}

package() {
  cd "${srcdir}/tu_paquete/src/"
  make DESTDIR="${pkgdir}" install
}
```

📌 **Guarda este contenido en un archivo llamado `PKGBUILD` dentro del directorio `tu_paquete`**.

---

## 5️⃣ Crear el Archivo `.SRCINFO`
AUR requiere un archivo `.SRCINFO` para describir el paquete. Genéralo con:

```bash
makepkg --printsrcinfo > .SRCINFO
```

💡 **Consejo:** Actualiza `.SRCINFO` siempre que modifiques el `PKGBUILD`.

---

## 6️⃣ Probar el PKGBUILD Localmente
Antes de enviarlo, verifica si el **PKGBUILD** funciona correctamente:

```bash
makepkg -si
```

✔️ Esto descarga dependencias, compila e instala el paquete localmente.
❌ Corrige cualquier error que aparezca.

---

## 7️⃣ Agregar Archivos a Git y Hacer Commit
Agrega los archivos al repositorio Git:

```bash
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: Add tu_paquete package"
```

---

## 8️⃣ Enviar a AUR
Sube el repositorio a AUR:

```bash
git push origin master
```

📌 **Si es la primera vez, esto creará el paquete en AUR.**

🔗 Ve el resultado en: [aur.archlinux.org/packages/tu_paquete](https://aur.archlinux.org/packages/tu_paquete)

---

## 9️⃣ Mantener el Paquete
Como mantenedor, serás responsable de:

✅ Actualizar **pkgrel** o **PKGBUILD** según sea necesario (ej.: cambios en el repositorio upstream).
✅ Asegurar que el paquete siga siendo funcional para los usuarios.

---

🎉 **¡Listo! Tu paquete ahora está en AUR, disponible para la comunidad de Arch Linux.**

📚 Para más información, revisa los pasos o consulta la [documentación oficial de AUR](https://wiki.archlinux.org/title/Arch_User_Repository).

