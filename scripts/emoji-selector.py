#!/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script implements a graphical user interface (GUI) application for searching and displaying emojis using the PyQt6 library. 
Users can enter keywords into a search bar, and the application dynamically filters and displays a list of matching emojis along 
with their descriptions. The script includes a predefined dictionary of emojis and their meanings, and it utilizes a custom 
emoji font to ensure proper rendering. The emoji list updates in real-time as the user types, enhancing the search experience. 
This tool is particularly useful for quickly finding emojis based on descriptive keywords.

Dependencies:
1. 'PyQt6' - Third-party library for creating the GUI (install via pip).
2. 'sys' - Native library for system-specific parameters and functions (no installation needed).
3. 'NotoColorEmoji.ttf' - Custom emoji font file (ensure it is present in an accessible directory).

Installation of Dependencies:
- Install 'PyQt6' using pip:

  pip install PyQt6
  
- Ensure that the 'NotoColorEmoji.ttf' font file is available in the same directory as the script for proper emoji rendering.
"""

import sys
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import QApplication, QWidget, QVBoxLayout, QLineEdit, QListWidget, QListWidgetItem
from PyQt6.QtGui import QFontDatabase, QFont

# Certifique-se de ter o arquivo NotoColorEmoji.ttf em um diretório acessível
EMOJI_FONT_PATH = "NotoColorEmoji.ttf"

# Dicionário de emojis (com emojis adicionais)
emoji_dict = {
    "😀": "Grinning Face",
    "😃": "Grinning Face with Big Eyes",
    "😄": "Grinning Face with Smiling Eyes",
    "😁": "Beaming Face with Smiling Eyes",
    "😆": "Grinning Squinting Face",
    "😅": "Grinning Face with Sweat",
    "🤣": "Rolling on the Floor Laughing",
    "😂": "Face with Tears of Joy",
    "🙂": "Slightly Smiling Face",
    "🙃": "Upside-Down Face",
    "😉": "Winking Face",
    "😊": "Smiling Face with Smiling Eyes",
    "😍": "Smiling Face with Heart-Eyes",
    "🥰": "Smiling Face with Hearts",
    "😘": "Face Blowing a Kiss",
    "😎": "Smiling Face with Sunglasses",
    "🤩": "Star-Struck",
    "🤗": "Hugging Face",
    "🤔": "Thinking Face",
    "🤨": "Face with Raised Eyebrow",
    "😑": "Expressionless Face",
    "😶": "Face Without Mouth",
    "😋": "Face Savoring Food",
    "😛": "Face with Tongue",
    "🤪": "Zany Face",
    "😜": "Winking Face with Tongue",
    "😝": "Squinting Face with Tongue",
    "🎮": "Gamepad / Joystick",
    "🕹": "Joystick / Gamepad",
    # Adicione mais emojis aqui
}

class EmojiSearchWidget(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Emoji Search')
        self.setup_ui()

    def setup_ui(self):
        layout = QVBoxLayout()
        
        self.search_input = QLineEdit()
        self.search_input.setPlaceholderText("Digite uma palavra-chave")
        self.search_input.textChanged.connect(self.search_emojis)
        layout.addWidget(self.search_input)
        
        self.emoji_list = QListWidget()
        layout.addWidget(self.emoji_list)
        
        self.setLayout(layout)
        
    def search_emojis(self, keyword):
        self.emoji_list.clear()
        keyword = keyword.lower()
        
        if keyword:
            matching_emojis = {emoji: description for emoji, description in emoji_dict.items() if keyword in description.lower()}
            for emoji in matching_emojis.keys():
                item = QListWidgetItem(emoji)
                item.setFont(QFont("Noto Color Emoji", 16))
                self.emoji_list.addItem(item)

def load_emoji_font():
    # Carrega a fonte dos emojis
    font_id = QFontDatabase.addApplicationFont(EMOJI_FONT_PATH)
    font_families = QFontDatabase.applicationFontFamilies(font_id)
    if font_families:
        emoji_font = QFont(font_families[0])
        return emoji_font


if __name__ == '__main__':
    app = QApplication(sys.argv)

    # Carrega a fonte dos emojis
    emoji_font = load_emoji_font()
    if emoji_font is not None:
        app.setFont(emoji_font)

    window = EmojiSearchWidget()
    window.show()

    sys.exit(app.exec())



