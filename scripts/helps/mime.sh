default_mime()
{
	cat <<'EOF' | less -R -i
# Mime tips for file associations

# Directory
xdg-mime default org.gnome.Nautilus.desktop inode/directory
xdg-mime default org.gnome.Nautilus.desktop inode/directory application/x-gnome-saved-search

# Text files
xdg-mime default gedit.desktop text/plain
xdg-mime default mark.desktop text/markdown
xdg-mime default laxlax.desktop application/x-latex
xdg-mime default libreoffice-writer.desktop application/vnd.oasis.opendocument.text
xdg-mime default libreoffice-writer.desktop application/msword
xdg-mime default libreoffice-writer.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document

# Spreadsheets
xdg-mime default libreoffice-calc.desktop application/vnd.oasis.opendocument.spreadsheet
xdg-mime default libreoffice-calc.desktop application/vnd.ms-excel
xdg-mime default libreoffice-calc.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet

# Presentations
xdg-mime default libreoffice-impress.desktop application/vnd.oasis.opendocument.presentation
xdg-mime default libreoffice-impress.desktop application/vnd.ms-powerpoint
xdg-mime default libreoffice-impress.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation
xdg-mime default libreoffice-impress.desktop application/vnd.apple.keynote

# Shell scripts
xdg-mime default code.desktop text/x-ini
xdg-mime default code.desktop text/x-shellscript
xdg-mime default code.desktop application/x-shellscript

# C/C++ source code
xdg-mime default code.desktop text/x-csrc
xdg-mime default code.desktop text/x-c++src

# Python source code
xdg-mime default code.desktop text/x-python

# HTML files
xdg-mime default firefox.desktop text/html
xdg-mime default google-chrome.desktop text/html

# PDF files
xdg-mime default org.gnome.Evince.desktop application/pdf

# Image files
xdg-mime default eog.desktop image/png
xdg-mime default eog.desktop image/jpeg
xdg-mime default eog.desktop image/gif
xdg-mime default eog.desktop image/bmp
xdg-mime default eog.desktop image/tiff
xdg-mime default eog.desktop image/svg+xml
xdg-mime default eog.desktop image/webp
xdg-mime default eog.desktop image/heic

# Audio files
xdg-mime default vlc.desktop audio/mpeg
xdg-mime default vlc.desktop audio/ogg
xdg-mime default vlc.desktop audio/x-wav
xdg-mime default vlc.desktop audio/x-m4a
xdg-mime default vlc.desktop audio/flac
xdg-mime default vlc.desktop audio/x-aac
xdg-mime default vlc.desktop audio/x-ms-wma

# Video files
xdg-mime default vlc.desktop video/mp4
xdg-mime default vlc.desktop video/quicktime
xdg-mime default vlc.desktop video/x-msvideo
xdg-mime default vlc.desktop video/x-matroska
xdg-mime default vlc.desktop video/x-flv
xdg-mime default vlc.desktop video/x-ms-wmv
xdg-mime default vlc.desktop video/webm

# Archives
xdg-mime default file-roller.desktop application/x-tar
xdg-mime default file-roller.desktop application/zip
xdg-mime default file-roller.desktop application/x-7z-compressed
xdg-mime default file-roller.desktop application/x-rar-compressed
xdg-mime default file-roller.desktop application/x-bzip2
xdg-mime default file-roller.desktop application/x-xz

# Virtual Reality
xdg-mime default firefox.desktop x-world/x-vrml
xdg-mime default firefox.desktop model/vrml

# Calendars
xdg-mime default gnome-calendar.desktop text/calendar

Or edit file:
~/.config/mimeapps.list


EOF
}
