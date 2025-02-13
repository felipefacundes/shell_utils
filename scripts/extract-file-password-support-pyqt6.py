#!/usr/bin/env python
# License: GPLv3
# Credits: Felipe Facundes

"""
This Python script provides a graphical user interface (GUI) for extracting and compressing files using the PyQt6 library. 
It allows users to manage various compressed file formats easily, offering options for password protection and different compression types.

Key Features:
1. File Extraction: Supports a wide range of formats including tar, zip, rar, and more, with the ability to handle password-protected files.
2. File Compression: Users can compress files and folders into formats such as zip, 7z, and tar, with options for password protection.
3. Graphical User Interface: Utilizes PyQt6 to create an interactive GUI for file selection, password input, and displaying output messages.
4. Real-time Output Display: The output of extraction and compression processes is shown in a dedicated output window, allowing users 
   to monitor progress and results.
5. Error Handling: Provides user feedback through message boxes for unsupported file types, successful operations, and errors during 
   extraction or compression.

This script is a comprehensive tool for users needing to manage compressed files efficiently while providing a user-friendly and interactive experience.

Dependencies:
1. 'PyQt6' - Third-party library for creating the GUI (install via pip).
2. 'subprocess' - Native library for running shell commands (no installation needed).
3. 'os' - Native library for interacting with the operating system (no installation needed).
4. 'sys' - Native library for system-specific parameters and functions (no installation needed).

Installation of Dependencies:
- Install 'PyQt6' using pip:

  pip install PyQt6
"""

import sys
import os
import subprocess
from PyQt6.QtWidgets import QApplication, QFileDialog, QMessageBox, QInputDialog, QVBoxLayout, QWidget, QTextEdit, QLineEdit

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

def extract(file, folder, output_window, password=None):
    extension = os.path.splitext(file)[1].lower()

    if extension.endswith('.tar.gz') or extension.endswith('.tar.xz') or extension.endswith('.tar.zst'):
        inner_extension = os.path.splitext(os.path.splitext(file)[0])[1].lower()
        tar_file = os.path.splitext(file)[0]

        if inner_extension == '.gz':
            subprocess.run(f"tar xvzf {tar_file} -C {folder} --overwrite", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        elif inner_extension == '.xz':
            subprocess.run(f"tar xvJf {tar_file} -C {folder} --overwrite", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        elif inner_extension == '.zst':
            tar_command = f"tar xf {tar_file} -C {folder} --overwrite"
            subprocess.run(tar_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            
            zstd_command = f"zstd -d {os.path.join(folder, os.path.splitext(os.path.basename(tar_file))[0])} -o {folder}"
            subprocess.run(zstd_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
            os.remove(os.path.join(folder, os.path.splitext(os.path.basename(tar_file))[0]))
        
        os.remove(tar_file)
        file = os.path.join(folder, os.path.basename(file))

    command = ""

    if extension == '.tar.bz2':
        command = f"tar xvjf {file} -C {folder} --overwrite"
    elif extension.endswith('.tar'):
        command = f"tar xvf {file} -C {folder} --overwrite"
    elif extension.endswith('.gz'):
        command = f"gunzip -c {file} > {os.path.join(folder, os.path.splitext(os.path.basename(file))[0])} --force"
    elif extension.endswith('.xz'):
        command = f"unxz -c {file} > {os.path.join(folder, os.path.splitext(os.path.basename(file))[0])} --force"
    elif extension.endswith('.zst'):
        command = f"zstd -d {file} -o {os.path.join(folder, os.path.splitext(os.path.basename(file))[0])} --force"
    elif extension == '.lzma':
        command = f"unlzma {file} -c > {folder} --force"
    elif extension == '.bz2':
        command = f"bunzip2 {file} -c > {folder} --force"
    elif extension == '.rar':
        if password:
            command = f"unrar x -ad -p'{password}' {file} {folder}"
        else:
            command = f"unrar x -ad {file} {folder}"
    elif extension == '.tgz':
        command = f"tar xvzf {file} -C {folder} --overwrite"
    elif extension == '.tbz2':
        command = f"tar xvjf {file} -C {folder} --overwrite"
    elif extension == '.zip':
        if password:
            command = f"unzip -o -P '{password}' {file} -d {folder}"
        else:
            command = f"unzip -o {file} -d {folder}"
    elif extension == '.z':
        command = f"uncompress {file} -c > {folder} --force"
    elif extension == '.7z':
        if password:
            command = f"7z x -p'{password}' {file} -o{folder} -y"
        else:
            command = f"7z x {file} -o{folder} -y"
    elif extension == '.iso':
        if password:
            command = f"7z x -p'{password}' {file} -o{folder} -y"
        else:
            command = f"7z x {file} -o{folder} -y"
    elif extension == '.exe':
        command = f"cabextract {file} -d {folder} --overwrite"
    else:
        QMessageBox.critical(None, "Error", "Unsupported file extension!")
        return

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

def compress_file(file, output_window, compression_type):
    folder = os.path.dirname(file)
    file_name = os.path.basename(file)

    command = ""

    if compression_type == 'zip':
        command = f"zip {file}.zip {file}"
    elif compression_type == 'zst':
        command = f"zstd --ultra -22 {file} -o {file}.zst"
    elif compression_type == '7z':
        command = f"7z a {file}.7z {file}"
    elif compression_type == 'rar':
        command = f"rar a -p {file}.rar {file}"
    elif compression_type == 'tar.gz':
        command = f"tar cvzf {file}.tar.gz -C {folder} {file_name}"
    elif compression_type == 'tar.xz':
        command = f"tar cvJf {file}.tar.xz -C {folder} {file_name}"
    elif compression_type == 'tar.zst':
        command = f"tar cvf {file}.tar -C {folder} {file_name}"
        subprocess.run(command, shell=True)
        command = f"zstd --ultra -22 {file}.tar -o {file}.tar.zst"
        subprocess.run(command, shell=True)
        os.remove(f"{file}.tar")
    elif compression_type == 'tar':
        command = f"tar cvf {file}.tar -C {folder} {file_name}"
    else:
        QMessageBox.critical(None, "Error", "Invalid compression type!")
        return

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

        with open(os.path.join(folder, "compression_output.txt"), "w") as file:
            file.write(output)

        if process.returncode == 0:
            QMessageBox.information(None, "Success", "File compressed successfully!")
        else:
            QMessageBox.critical(None, "Error", "An error occurred during compression!")

def compress_folder(folder, output_window, compression_type):
    folder_name = os.path.basename(folder)

    command = ""

    if compression_type == 'zip':
        command = f"cd {os.path.dirname(folder)} && zip -r {folder_name}.zip {folder_name}"
    elif compression_type == 'zst':
        tar_command = f"cd {os.path.dirname(folder)} && tar cf {folder_name}.tar {folder_name}"
        subprocess.run(tar_command, shell=True)

        zstd_command = f"cd {os.path.dirname(folder)} && zstd --ultra -22 {folder_name}.tar -o {folder_name}.tar.zst"
        subprocess.run(zstd_command, shell=True)

        os.remove(f"{folder_name}.tar")
    elif compression_type == '7z':
        command = f"cd {os.path.dirname(folder)} && 7z a {folder_name}.7z {folder_name}"
    elif compression_type == 'rar':
        command = f"cd {os.path.dirname(folder)} && rar a -p {folder_name}.rar {folder_name}"
    elif compression_type == 'tar.gz':
        command = f"cd {os.path.dirname(folder)} && tar cvzf {folder_name}.tar.gz {folder_name}"
    elif compression_type == 'tar.xz':
        command = f"cd {os.path.dirname(folder)} && tar cvJf {folder_name}.tar.xz {folder_name}"
    elif compression_type == 'tar.zst':
        command = f"cd {os.path.dirname(folder)} && tar cf {folder_name}.tar {folder_name} && zstd --ultra -22 {folder_name}.tar -o {folder_name}.tar.zst && rm {folder_name}.tar"
    elif compression_type == 'tar':
        command = f"cd {os.path.dirname(folder)} && tar cvf {folder_name}.tar {folder_name}"
    else:
        QMessageBox.critical(None, "Error", "Invalid compression type!")
        return

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

        with open(os.path.join(folder, "compression_output.txt"), "w") as file:
            file.write(output)

        if process.returncode == 0:
            QMessageBox.information(None, "Success", "Folder compressed successfully!")
        else:
            QMessageBox.critical(None, "Error", "An error occurred during compression!")

def compress_dialog():
    compression_type, _ = QInputDialog.getItem(None, "Choose a compression type", "Compression Type", ["zip", "zst", "7z", "rar", "tar.gz", "tar.xz", "tar.zst", "tar"])
    option, _ = QInputDialog.getItem(None, "Choose an option", "Option", ["Compress file", "Compress folder"])

    if option == "Compress file":
        file, _ = QFileDialog.getOpenFileName(None, "Choose a file to compress", "", "")
        if not file:
            sys.exit(0)

        output_window = OutputWindow()
        output_window.show()

        compress_file(file, output_window, compression_type)
    elif option == "Compress folder":
        folder = QFileDialog.getExistingDirectory(None, "Choose a folder to compress", "")
        if not folder:
            sys.exit(0)

        output_window = OutputWindow()
        output_window.show()

        compress_folder(folder, output_window, compression_type)

def extract_dialog():
    while True:
        options = [
            "Extract here",
            "Extract to a folder",
            "Create a compressed file"
        ]
        option, _ = QInputDialog.getItem(None, "Choose an option", "Option", options)

        if option == "Extract here":
            file, _ = QFileDialog.getOpenFileName(None, "Choose a compressed file", "", "")
            if not file:
                sys.exit(0)

            folder = os.path.dirname(file)
            output_window = OutputWindow()
            output_window.show()

            password, ok = QInputDialog.getText(None, "Enter Password", "Please enter the password:", QLineEdit.EchoMode.Password)
            if not ok:
                sys.exit(0)

            password = password.strip()

            extract(file, folder, output_window, password)
        elif option == "Extract to a folder":
            file, _ = QFileDialog.getOpenFileName(None, "Choose a compressed file", "", "")
            if not file:
                sys.exit(0)

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
        elif option == "Create a compressed file":
            compress_dialog()

        answer = QMessageBox.question(None, "Continue", "Do you want to continue?",
                                      QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
        if answer == QMessageBox.StandardButton.No:
            sys.exit(0)

def main():
    app = QApplication(sys.argv)
    extract_dialog()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
