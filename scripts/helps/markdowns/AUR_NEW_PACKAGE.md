# 📦 Steps to Add a PKGBUILD to AUR

Welcome! This guide details how to add a **PKGBUILD** to the **Arch User Repository (AUR)** in a simple and effective way. Follow the steps below to create, test, and successfully submit your package.

---

## 1️⃣ Create an AUR Account
Go to [aur.archlinux.org](https://aur.archlinux.org) and create an account if you don't have one yet.

### 📌 Prerequisites:
- A **valid email**.
- An **SSH key** to interact with AUR via Git.

---

## 2️⃣ Set Up Your SSH Key
If you don’t have an SSH key yet, generate one with the following command:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

### 🔑 Add the public key to AUR:
1. Copy the contents of `~/.ssh/id_ed25519.pub`.
2. Go to **"My Account"** on the AUR website.
3. Paste the key in **"SSH Public Key"**.

---

## 3️⃣ Clone the AUR Repository for the Package
Each package in AUR has its own Git repository. Since **your_package** is new, you will create an empty repository:

```bash
git clone ssh://aur@aur.archlinux.org/your_package.git

Or:

git clone https://aur.archlinux.org/your_package.git
```

📌 **Note:** If the package does not exist yet, AUR will allow its creation on the first `push`.

---

## 4️⃣ Add the PKGBUILD to the Repository
Enter the cloned directory:

```bash
cd your_package
```

Copy the **PKGBUILD** to this directory. Example:

```bash
# Maintainer: Felipe Facundes <felipefacundes@example.com> # Use your real email

pkgname=your_package
pkgver=0.1  # Initial example, will be automatically updated
pkgrel=1
pkgdesc="Description for your package"
arch=('i686' 'x86_64')
url="http://github.com/your_name/your_repo/"
license=('GPL')
depends=('python' 'bash' 'etc')
makedepends=('git' 'boost')
source=("git+${url}.git")
md5sums=('SKIP')

pkgver() {
  cd "${srcdir}/your_package/src" || true
  echo "r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)"
}

build() {
  cd "${srcdir}/your_package/src/"
  autoconf
  ./configure
  make
}

package() {
  cd "${srcdir}/your_package/src/"
  make DESTDIR="${pkgdir}" install
}
```

📌 **Save this content in a file named `PKGBUILD` inside the `your_package` directory**.

---

## 5️⃣ Create the `.SRCINFO` File
AUR requires a `.SRCINFO` file to describe the package. Generate it with:

```bash
makepkg --printsrcinfo > .SRCINFO
```

💡 **Tip:** Update `.SRCINFO` whenever you modify the `PKGBUILD`.

---

## 6️⃣ Test the PKGBUILD Locally
Before submitting, check if the **PKGBUILD** works correctly:

```bash
makepkg -si
```

✔️ This downloads dependencies, compiles, and installs the package locally.
❌ Fix any errors that appear.

---

## 7️⃣ Add Files to Git and Commit
Add the files to the Git repository:

```bash
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: Add your_package package"
```

---

## 8️⃣ Push to AUR
Push the repository to AUR:

```bash
git push origin master
```

📌 **If this is the first time, this will create the package on AUR.**

🔗 See the result at: [aur.archlinux.org/packages/your_package](https://aur.archlinux.org/packages/your_package)

---

## 9️⃣ Maintain the Package
As a maintainer, you will be responsible for:

✅ Updating **pkgrel** or **PKGBUILD** as needed (e.g., changes in the upstream repository).
✅ Ensuring the package remains functional for users.

---

🎉 **Done! Your package is now on AUR, available to the Arch Linux community.**

📚 For more information, review the steps or check the [official AUR documentation](https://wiki.archlinux.org/title/Arch_User_Repository).

