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

Shell Utils is an educational framework designed to make shell programming accessible and powerful. It is the result of extensive work over many years, now available on GitHub. With over 280 documented scripts, it caters to both beginners and advanced users. Its main differentiator is the ability to interact with the major shells: **Bash, Zsh, and Fish**.

This repo is intended to extend the shell and contain useful and readable functions that help developers to maintaine their scripts easier and neatly.

✅ Includes third-party scripts, such as those from [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) *(credits maintained in the scripts)*.

### ✨ Key Features

- Dynamic recognition of scripts, functions, variables, and aliases
- Comprehensive documentation and help menus
- Shell compatibility (fish, zsh, bash)
- Rich collection of utility scripts
- Educational resources and tutorials

📌 The `help_shell` script lists functions like `sed_info` (to assist with using sed), providing quick tutorials on Linux commands. To create a simple function, just create a file `function.sh` and store it in `~/.shell_utils/scripts/helps/`. The `help_shell` script will be able to read them and display a complete list of educational functions and much more.

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

## 🔧 Features and Tools

- **Alarm**: Multilingual alarm, capable of executing external commands, snooze function, and more.
- **Markdown Reader**: An enhanced markdown reader combining clean formatting with optional syntax highlighting.
- **Calendar**: Full calendar with holiday support
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
- **Integration with Third-Party Tools**: Including scripts from ["Fred's Imagemagick"](http://www.fmwconcepts.com/imagemagick/index.php)

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

Contributions are welcome! Feel free to submit a Pull Request. For significant changes, please open an issue first to discuss what you would like to change.

## 📜 License

This project is licensed under the GPLv3 License - see the [LICENSE](LICENSE) file for details.

## 👏 Credits

- Original creator: [Felipe Facundes](https://github.com/felipefacundes)
- Special thanks to all contributors and to [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) for some included scripts

---

<div align="center">
  
**Made with ❤️ by the Shell Utils community**

[Report Bug](https://github.com/felipefacundes/shell_utils/issues) · [Request Feature](https://github.com/felipefacundes/shell_utils/issues)

</div>