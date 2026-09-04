# Shell Utils Framework 🐚

[![pt-BR](https://img.shields.io/badge/lang-pt--BR-green.svg)](./README_pt.md) [![es](https://img.shields.io/badge/lang-es-yellow.svg)](./README_es.md) [![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)

<div align="center">
  
![Shell Utils Logo](./icons/logo.png)

*A Dynamic Collection of Shell Scripts with Educational Purpose*

![GitHub stars](https://img.shields.io/github/stars/felipefacundes/shell_utils?style=social)
![GitHub forks](https://img.shields.io/github/forks/felipefacundes/shell_utils?style=social)
![GitHub issues](https://img.shields.io/github/issues/felipefacundes/shell_utils)
![GitHub license](https://img.shields.io/github/license/felipefacundes/shell_utils)

</div>

## 🌟 Overview

Shell Utils is an educational framework designed to make shell programming accessible and powerful. It is the result of exhaustive work over many years, now available on GitHub. With over 400 documented scripts, it serves both beginners and advanced users. Its main differentiator is the ability to interact with the main shells: **Bash, Zsh, and Fish**.

This repository aims to extend the shell and contain useful and readable functions that help developers maintain their scripts more easily and organized.

✅ Includes third-party scripts, such as those from [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) *(credits maintained in the scripts)*.

### ✨ Key Features

- Dynamic recognition of scripts, functions, variables, and aliases
- Comprehensive documentation and help menus
- Cross-shell compatibility (fish, zsh, bash)
- Rich collection of utility scripts
- Educational resources and tutorials
- **Persistent folder structure** for user customizations that are not affected by framework updates

📌 The `help_shell` script lists functions like `docker_help` (to assist with using docker), providing quick tutorials on Linux commands. To create a simple function, just create a `function.sh` file and store it in `~/.local/shell_utils/scripts/helps/`. The `help_shell` script will be able to read them and show a complete list of pedagogical functions and much more.

## 📁 Directory Structure

```bash
~/.shell_utils/
├── scripts/     # Main scripts
│   ├── faqs/    # Tutorial scripts and guides
│   └── helps/   # Educational helper functions
├── functions/   # Custom functions
├── variables/   # Environment variables
└── aliases/     # Shell aliases
```

## 🛡️ Persistent Structure for Users

To ensure your customizations are preserved during automatic framework updates, use the persistent directory structure:

```bash
~/.local/share/shell_utils/
├── functions/   # Your custom functions (safe from updates)
├── variables/   # Your custom environment variables
├── aliases/     # Your custom aliases
├── priority/    # Scripts with loading priority
└── scripts/
    ├── utils/   # Your utility scripts
    └── helps/
        └── markdowns/  # Your custom documentation
```

### 🔄 How It Works:
- **`~/.shell_utils/`** - Main framework (updatable via Git)
- **`~/.local/share/shell_utils/`** - Your customizations (persistent and safe)
- **Loading Order**: First the framework, then your customizations
- **Automatic Updates**: Your files in `~/.local/shell_utils/` are never overwritten

### 💡 To Add Your Customizations:
```bash
# Your custom functions
vim ~/.local/shell_utils/functions/my_function.sh

# Your custom aliases  
vim ~/.local/shell_utils/aliases/my_aliases.sh

# Your environment variables
vim ~/.local/shell_utils/variables/my_variables.sh
```

## 🔧 Resources and Tools

- **Alarm**: Multilingual alarm, with ability to run external commands, snooze function, and much more.
- **Markdown Reader**: An enhanced markup reader combining clean formatting with optional syntax highlighting.
- **Calendar**: Complete calendar with holiday support
- **Video Tools**: Screen recorder and video managers
- **Audio Tools**: Generate audio frequencies and sound managers
- **Image Processing Tools**: Convert, resize, and manipulate images
- **Theme Management**:
  - GRUB themes
  - Terminal themes
  - ASCII art collections
- **Color Utilities**:
  - ANSI color palette
  - Hex to ANSI converter
- **Window Manager Tools**: Support for i3, awesome, openbox, and others
- **Third-Party Tool Integration**: Including scripts from ["Fred's Imagemagick"](http://www.fmwconcepts.com/imagemagick/index.php)

## 🚀 Installation

### Option 1: One-Line Installation
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/felipefacundes/shell_utils/refs/heads/main/install.sh)"
```

### Option 2: Manual Installation
```bash
git clone https://github.com/felipefacundes/shell_utils ~/.shell_utils
bash ~/.shell_utils/install.sh
```

## 🔄 Dependencies

The installer automatically detects your shell (fish, zsh, or bash) and installs the necessary dependencies:
- For bash users: oh-my-bash
- For zsh users: oh-my-zsh

## 🤝 Contributing

Contributions are welcome! Feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📜 License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details.

## 👏 Credits

- Original creator: [Felipe Facundes](https://github.com/felipefacundes)
- Special thanks to all contributors and [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) for some included scripts

---

<div align="center">
  
**Made with ❤️ by the Shell Utils community**

[Report Bug](https://github.com/felipefacundes/shell_utils/issues) · [Request Feature](https://github.com/felipefacundes/shell_utils/issues)

</div>