#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script provides a graphical user interface for extracting various compressed file formats using PyQt6. 
Users can select a file to extract and choose whether to extract it in the current directory or a specified folder, 
with the option to create a new folder if desired. The script executes the appropriate extraction command based on 
the file extension and displays the output in a dedicated window. It also logs the extraction results to a text file 
and notifies the user of success or errors during the process.

Dependencies:
1. PyQt6 (third-party, install via pip)
2. subprocess (native, no installation needed)
3. os (native, no installation needed)
4. sys (native, no installation needed)

Installation of Dependencies:
- To install the third-party dependency, run the following command:

  pip install PyQt6
"""

import sys
import os
import subprocess
from PyQt6.QtWidgets import QApplication, QFileDialog, QMessageBox, QInputDialog, QVBoxLayout, QWidget, QTextEdit

class OutputWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Extraction Output")
        self.layout = QVBoxLayout()
        self.text_edit = QTextEdit()
        self.text_edit.setReadOnly(True)
        self.layout.addWidget(self.text_edit)
        self.setLayout(self.layout)

    def append_output(self, text):
        self.text_edit.append(text)

def extract(file, folder, output_window):
    extension = os.path.splitext(file)[1].lower()

    command = ""

    if extension == '.tar.bz2':
        command = f"tar xvjf {file} -C {folder}"
    elif extension == '.tar.gz':
        command = f"tar xvzf {file} -C {folder}"
    elif extension == '.tar.xz':
        command = f"tar xvJf {file} -C {folder}"
    elif extension == '.lzma':
        command = f"unlzma {file} -c > {folder}"
    elif extension == '.bz2':
        command = f"bunzip2 {file} -c > {folder}"
    elif extension == '.rar':
        command = f"unrar x -ad {file} {folder}"
    elif extension == '.gz':
        command = f"gunzip {file} -c > {folder}"
    elif extension == '.tar':
        command = f"tar xvf {file} -C {folder}"
    elif extension == '.tbz2':
        command = f"tar xvjf {file} -C {folder}"
    elif extension == '.tgz':
        command = f"tar xvzf {file} -C {folder}"
    elif extension == '.zip':
        command = f"unzip {file} -d {folder}"
    elif extension == '.z':
        command = f"uncompress {file} -c > {folder}"
    elif extension == '.7z':
        command = f"7z x {file} -o{folder}"
    elif extension == '.iso':
        command = f"7z x {file} -o{folder}"
    elif extension == '.xz':
        command = f"unxz {file} -c > {folder}"
    elif extension == '.exe':
        command = f"cabextract {file} -d {folder}"

    if command:
        process = subprocess.Popen(
            command,
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT
        )

        output = ""
        while True:
            line = process.stdout.readline().decode().strip()
            if not line and process.poll() is not None:
                break

            output += line + "\n"
            output_window.append_output(line)

        with open(os.path.join(folder, "extraction_output.txt"), "w") as file:
            file.write(output)

        if process.returncode == 0:
            QMessageBox.information(None, "Success", "File extracted successfully!")
        else:
            QMessageBox.critical(None, "Error", "An error occurred during extraction!")

def extract_dialog():
    while True:
        file, _ = QFileDialog.getOpenFileName(None, "Choose a compressed file", "", "")
        if not file:
            sys.exit(0)

        folder = os.path.dirname(file)
        option, _ = QInputDialog.getItem(None, "Choose an option", "Option", ["Extract here", "Extract to a folder"])

        if option == "Extract here":
            if folder == "":
                folder = os.getcwd()  # Set the current directory as the extraction folder if the file does not contain an absolute path

            output_window = OutputWindow()
            output_window.show()

            extract(file, folder, output_window)
        elif option == "Extract to a folder":
            answer = QMessageBox.question(None, "Create new folder?", "Do you want to create a new folder to extract the file?",
                                          QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)

            if answer == QMessageBox.StandardButton.Yes:
                folder, _ = QFileDialog.getSaveFileName(None, "Choose the name and location of the new folder", "", "")
                os.makedirs(folder, exist_ok=True)
            else:
                folder = QFileDialog.getExistingDirectory(None, "Choose an existing folder", "")

            output_window = OutputWindow()
            output_window.show()

            extract(file, folder, output_window)

        answer = QMessageBox.question(None, "Extract Another File", "Do you want to extract another file?",
                                      QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if answer == QMessageBox.StandardButton.No:
            sys.exit(0)

def main():
    app = QApplication(sys.argv)
    extract_dialog()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
