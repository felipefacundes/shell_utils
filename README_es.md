# Shell Utils Framework 🐚

[![pt-BR](https://img.shields.io/badge/lang-pt--BR-green.svg)](./README_pt.md) [![es](https://img.shields.io/badge/lang-es-yellow.svg)](./README_es.md) [![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)

<div align="center">
  
![Shell Utils Logo](./icons/logo.png)

*Una Colección Dinámica de Scripts Shell con Propósito Educacional*

![GitHub stars](https://img.shields.io/github/stars/felipefacundes/shell_utils?style=social)
![GitHub forks](https://img.shields.io/github/forks/felipefacundes/shell_utils?style=social)
![GitHub issues](https://img.shields.io/github/issues/felipefacundes/shell_utils)
![GitHub license](https://img.shields.io/github/license/felipefacundes/shell_utils)

</div>

## 🌟 Visión General

Shell Utils es un marco educativo diseñado para hacer que la programación en shell sea accesible y poderosa. Es el resultado de un trabajo exhaustivo durante muchos años, ahora disponible en GitHub. Con más de 280 scripts documentados, atiende tanto a principiantes como a usuarios avanzados. Su gran diferenciador es la capacidad de interactuar con los principales shells: **Bash, Zsh y Fish**.

✅ Incluye scripts de terceros, como los de [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) *(créditos mantenidos en los scripts)*.

### ✨ Características Principales

- Reconocimiento dinámico de scripts, funciones, variables y alias
- Documentación completa y menús de ayuda
- Compatibilidad entre shells (fish, zsh, bash)
- Rica colección de scripts utilitarios
- Recursos educativos y tutoriales

📌 El script `help_shell` lista funciones como `sed_info` (para ayudar con el uso de sed), proporcionando tutoriales rápidos sobre comandos de Linux. Para crear una función simple, solo crea un archivo `función.sh` y guárdalo en `~/.shell_utils/scripts/helps/`. El script `help_shell` podrá leerlos y mostrar una lista completa de funciones pedagógicas y mucho más.

## 📁 Estructura de Directorios

```bash
~/.shell_utils/
├── scripts/     # Scripts principales
│   ├── faqs/    # Scripts de tutorial y guías
│   └── helps/   # Funciones auxiliares educativas
├── functions/   # Funciones personalizadas
├── variables/   # Variables de entorno
└── aliases/     # Alias del shell
```

## 🔧 Recursos y Herramientas

- **Alarma**: Alarma multilingüe, con capacidad de ejecutar comandos externos, función de repetición y más.
- **Calendario**: Calendario completo con soporte para días festivos
- **Herramientas de Video**: Grabador de pantalla y administradores de videos
- **Herramientas de Audio**: Generar frecuencias de audio y administradores de sonido
- **Herramientas de Procesamiento de Imágenes**: Convertir, redimensionar y manipular imágenes
- **Gestión de Temas**:
  - Temas de GRUB
  - Temas de Terminal
  - Colecciones de arte ASCII
- **Utilidades de Color**:
  - Paleta de colores ANSI
  - Convertidor de Hex a ANSI
- **Herramientas para Gestores de Ventanas**: Soporte para i3, awesome, openbox y otros
- **Integración con Herramientas de Terceros**: Incluyendo scripts de ["Fred's Imagemagick"](http://www.fmwconcepts.com/imagemagick/index.php)

## 🚀 Instalación

### Opción 1: Instalación en Una Línea
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/felipefacundes/shell_utils/refs/heads/main/install.sh)"
```

### Opción 2: Instalación Manual
```bash
git clone https://github.com/felipefacundes/shell_utils ~/.shell_utils
bash ~/.shell_utils/install.sh
```

## 🔄 Dependencias

El instalador detecta automáticamente tu shell (fish, zsh o bash) e instala las dependencias necesarias:
- Para usuarios de bash: oh-my-bash
- Para usuarios de zsh: oh-my-zsh

## 🤝 Contribuyendo

¡Las contribuciones son bienvenidas! Siéntete libre de enviar un Pull Request. Para cambios importantes, por favor abre un issue primero para discutir lo que te gustaría cambiar.

## 📜 Licencia

Este proyecto está licenciado bajo la Licencia GPLv3 - consulta el archivo [LICENSE](LICENSE) para obtener detalles.

## 👏 Créditos

- Creador original: [Felipe Facundes](https://github.com/felipefacundes)
- Agradecimientos especiales a todos los contribuyentes y a [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) por algunos scripts incluidos

---

<div align="center">
  
**Hecho con ❤️ por la comunidad Shell Utils**

[Reportar Bug](https://github.com/felipefacundes/shell_utils/issues) · [Solicitar Recurso](https://github.com/felipefacundes/shell_utils/issues)

</div>