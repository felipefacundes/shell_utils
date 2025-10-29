# 📦 Passos para Adicionar o PKGBUILD ao AUR

Bem-vindo! Este guia detalha como adicionar um **PKGBUILD** ao **Arch User Repository (AUR)** de forma simples e eficaz. Siga os passos abaixo para criar, testar e enviar seu pacote com sucesso.

---

## 1️⃣ Crie uma Conta no AUR
Acesse [aur.archlinux.org](https://aur.archlinux.org) e crie uma conta, caso ainda não tenha.

### 📌 Pré-requisitos:
- Um **e-mail válido**.
- Uma **chave SSH** para interagir com o AUR via Git.

---

## 2️⃣ Configure sua Chave SSH
Se ainda não tiver uma chave SSH, gere uma com o seguinte comando:

```bash
ssh-keygen -t ed25519 -C "seu-email@example.com"
```

### 🔑 Adicione a chave pública ao AUR:
1. Copie o conteúdo de `~/.ssh/id_ed25519.pub`.
2. Vá para **"My Account"** no site do AUR.
3. Cole a chave em **"SSH Public Key"**.

---

## 3️⃣ Clone o Repositório AUR para o Pacote
Cada pacote no AUR tem seu próprio repositório Git. Como **seu_pacote** é novo, você criará um repositório vazio:

```bash
git clone ssh://aur@aur.archlinux.org/seu_pacote.git

Ou:

git clone https://aur.archlinux.org/seu_pacote.git
```

📌 **Nota:** Se o pacote ainda não existir, o AUR permitirá sua criação no primeiro `push`.

---

## 4️⃣ Adicione o PKGBUILD ao Repositório
Entre no diretório clonado:

```bash
cd seu_pacote
```

Copie o **PKGBUILD** revisado para esse diretório. Exemplo:

```bash
# Maintainer: Felipe Facundes <felipefacundes@example.com> # Use seu e-mail real

pkgname=seu_pacote
pkgver=0.1  # Exemplo inicial, será atualizado automaticamente
pkgrel=1
pkgdesc="Descrição para o seu pacote"
arch=('i686' 'x86_64')
url="http://github.com/seu_nome/seu_repo/"
license=('GPL')
depends=('python' 'bash' 'etc')
makedepends=('git' 'boost')
source=("git+${url}.git")
md5sums=('SKIP')

pkgver() {
  cd "${srcdir}/seu_pacote/src" || true
  echo "r$(git rev-list --count HEAD).$(git rev-parse --short HEAD)"
}

build() {
  cd "${srcdir}/seu_pacote/src/"
  autoconf
  ./configure
  make
}

package() {
  cd "${srcdir}/seu_pacote/src/"
  make DESTDIR="${pkgdir}" install
}
```

📌 **Salve esse conteúdo em um arquivo chamado `PKGBUILD` dentro do diretório `seu_pacote`**.

---

## 5️⃣ Crie o Arquivo `.SRCINFO`
O AUR exige um arquivo `.SRCINFO` para descrever o pacote. Gere-o com:

```bash
makepkg --printsrcinfo > .SRCINFO
```

💡 **Dica:** Atualize o `.SRCINFO` sempre que modificar o `PKGBUILD`.

---

## 6️⃣ Teste o PKGBUILD Localmente
Antes de enviar, verifique se o **PKGBUILD** funciona corretamente:

```bash
makepkg -si
```

✔️ Isso baixa as dependências, compila e instala o pacote localmente.
❌ Corrija quaisquer erros que apareçam.

---

## 7️⃣ Adicione os Arquivos ao Git e Faça o Commit
Adicione os arquivos ao repositório Git:

```bash
git add PKGBUILD .SRCINFO
git commit -m "Initial commit: Add seu_pacote package"
```

---

## 8️⃣ Envie para o AUR
Faça o **push** do repositório para o AUR:

```bash
git push origin master
```

📌 **Se for a primeira vez, isso criará o pacote no AUR.**

🔗 Veja o resultado em: [aur.archlinux.org/packages/seu_pacote](https://aur.archlinux.org/packages/seu_pacote)

---

## 9️⃣ Mantenha o Pacote
Como mantenedor, você será responsável por:

✅ Atualizar o **pkgrel** ou o **PKGBUILD** conforme necessário (ex.: mudanças no repositório upstream).
✅ Garantir que o pacote permaneça funcional para os usuários.

---

🎉 **Pronto! Seu pacote agora está no AUR, disponível para a comunidade Arch Linux.**

📚 Para mais informações, revise os passos ou consulte a [documentação oficial do AUR](https://wiki.archlinux.org/title/Arch_User_Repository).

