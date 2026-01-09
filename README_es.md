# Shell Utils Framework 🐚

[![pt-BR](https://img.shields.io/badge/lang-pt--BR-green.svg)](./README_pt.md) [![es](https://img.shields.io/badge/lang-es-yellow.svg)](./README_es.md) [![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)

<div align="center">
  
![Shell Utils Logo](./icons/logo.png)

*Una Colección Dinámica de Scripts Shell con Propósito Educativo*

![GitHub stars](https://img.shields.io/github/stars/felipefacundes/shell_utils?style=social)
![GitHub forks](https://img.shields.io/github/forks/felipefacundes/shell_utils?style=social)
![GitHub issues](https://img.shields.io/github/issues/felipefacundes/shell_utils)
![GitHub license](https://img.shields.io/github/license/felipefacundes/shell_utils)

</div>

## 🌟 Visión General

Shell Utils es un framework educativo diseñado para hacer la programación shell accesible y poderosa. Es el resultado de un trabajo exhaustivo de muchos años, ahora disponible en GitHub. Con más de 400 scripts documentados, atiende tanto a principiantes como a usuarios avanzados. Su gran diferencial es la capacidad de interactuar con los principales shells: **Bash, Zsh y Fish**.

Este repositorio tiene como objetivo extender el shell y contener funciones útiles y legibles que ayuden a los desarrolladores a mantener sus scripts de forma más fácil y organizada.

✅ Incluye scripts de terceros, como los de [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) *(créditos mantenidos en los scripts)*.

### ✨ Características Principales

- Reconocimiento dinámico de scripts, funciones, variables y alias
- Documentación integral y menús de ayuda
- Compatibilidad entre shells (fish, zsh, bash)
- Rica colección de scripts utilitarios
- Recursos educativos y tutoriales
- **Estructura de carpetas persistente** para personalizaciones del usuario que no son afectadas por las actualizaciones del framework

📌 El script `help_shell` lista funciones como `docker_help` (para ayudar en el uso de docker), proporcionando tutoriales rápidos sobre comandos de Linux. Para crear una función simple, basta con crear un archivo `función.sh` y almacenarlo en `~/.local/shell_utils/scripts/helps/`. El script `help_shell` será capaz de leerlos y mostrar una lista completa de funciones pedagógicas y mucho más.

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

## 🛡️ Estructura Persistente para Usuarios

Para garantizar que sus personalizaciones se preserven durante las actualizaciones automáticas del framework, utilice la estructura de directorios persistente:

```bash
~/.local/shell_utils/
├── functions/   # Sus funciones personalizadas (seguras contra actualizaciones)
├── variables/   # Sus variables de entorno personalizadas
├── aliases/     # Sus alias personalizados
├── priority/    # Scripts con prioridad de carga
└── scripts/
    ├── utils/   # Sus scripts utilitarios
    └── helps/
        └── markdowns/  # Su documentación personalizada
```

### 🔄 Cómo Funciona:
- **`~/.shell_utils/`** - Framework principal (actualizable vía Git)
- **`~/.local/shell_utils/`** - Sus personalizaciones (persistentes y seguras)
- **Orden de Carga**: Primero el framework, luego sus personalizaciones
- **Actualizaciones Automáticas**: Sus archivos en `~/.local/shell_utils/` nunca son sobrescritos

### 💡 Para Agregar Sus Personalizaciones:
```bash
# Sus funciones personalizadas
vim ~/.local/shell_utils/functions/mi_funcion.sh

# Sus alias personalizados  
vim ~/.local/shell_utils/aliases/mis_alias.sh

# Sus variables de entorno
vim ~/.local/shell_utils/variables/mis_variables.sh
```

## 🔧 Recursos y Herramientas

- **Alarma**: Alarma multilingüe, con capacidad de ejecutar comandos externos, función de posponer y mucho más.
- **Lector de Markdown**: Un lector mejorado de marcado que combina formato limpio con resaltado de sintaxis opcional.
- **Calendario**: Calendario completo con soporte para festivos
- **Herramientas de Video**: Grabador de pantalla y administradores de videos
- **Herramientas de Audio**: Generar frecuencias de audio y administradores de sonido
- **Herramientas de Procesamiento de Imagen**: Convertir, redimensionar y manipular imágenes
- **Gestión de Temas**:
  - Temas de GRUB
  - Temas de Terminal
  - Colecciones de arte ASCII
- **Utilidades de Colores**:
  - Paleta de colores ANSI
  - Conversor de Hex a ANSI
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

El instalador detecta automáticamente su shell (fish, zsh o bash) e instala las dependencias necesarias:
- Para usuarios bash: oh-my-bash
- Para usuarios zsh: oh-my-zsh

## 🤝 Contribuyendo

¡Las contribuciones son bienvenidas! Siéntase libre de enviar un Pull Request. Para cambios importantes, por favor, abra un issue primero para discutir lo que le gustaría cambiar.

## 📜 Licencia

Este proyecto está bajo la Licencia GPLv3 - consulte el archivo [LICENSE](LICENSE) para obtener detalles.

## 👏 Créditos

- Creador original: [Felipe Facundes](https://github.com/felipefacundes)
- Agradecimientos especiales a todos los contribuidores y a [Fred's Imagemagick](http://www.fmwconcepts.com/imagemagick/index.php) por algunos scripts incluidos

---

<div align="center">
  
**Hecho con ❤️ por la comunidad Shell Utils**

[Reportar Error](https://github.com/felipefacundes/shell_utils/issues) · [Solicitar Característica](https://github.com/felipefacundes/shell_utils/issues)

</div>