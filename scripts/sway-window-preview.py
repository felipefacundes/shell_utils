#!/usr/bin/env python3
# License: GPLv3
# Credits: Felipe Facundes

# Script to create an Alt-Tab with thumbnails on Sway (GTK4)
# Requires: python-i3ipc, python-pillow, grim, gtk4

import i3ipc
from PIL import Image
import subprocess
import tempfile
import os
import sys
import gi
import time  # Added for small delay in capture

# Check if an instance is already running using pgrep
SCRIPT_NAME = os.path.basename(__file__)
result = subprocess.run(
    ['pgrep', '-f', f'python.*{SCRIPT_NAME}'],
    capture_output=True,
    text=True
)
# Count how many instances exist (current + others)
pids = result.stdout.strip().split()
if len(pids) > 1:  # More than one instance (including the one about to start)
    print(f"An instance of {SCRIPT_NAME} is already running. Exiting...")
    sys.exit(0)

gi.require_version('Gtk', '4.0')
from gi.repository import Gtk, Gdk, GLib

def check_running_instance():
    """Checks if an instance of the script is already running"""
    import psutil
    current_pid = os.getpid()
    current_script = os.path.abspath(__file__)
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        try:
            # Ignore the current process
            if proc.info['pid'] == current_pid:
                continue
            cmdline = proc.info['cmdline']
            if cmdline and len(cmdline) > 0:
                # Check if it's the same python script
                script_name = os.path.basename(current_script)
                if (('python' in cmdline[0] or 'python3' in cmdline[0]) and
                    script_name in ' '.join(cmdline)):
                    return True
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    return False

class SwaySwitcher(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='org.sway.switcher')
        self.i3 = None
        self.clients = []
        self.thumb_files = []
        self.thumb_size = (200, 165)
        self.items = []
        self.index = 0
        self.window = None

    def do_startup(self):
        Gtk.Application.do_startup(self)

    def do_activate(self):
        # Connect to Sway
        self.i3 = i3ipc.Connection()
        # Get windows from the current workspace
        tree = self.i3.get_tree()
        focused = tree.find_focused()
        if not focused:
            self.quit()
            return
        focused_id = focused.id  # Save ID of originally focused window
        # Get the focused workspace
        workspace = focused.workspace()
        workspace_name = workspace.name
        # Filter windows that actually belong to the focused workspace
        # This prevents floating windows from other workspaces from being included
        self.clients = []
        for node in tree.leaves():
            # Check if the window is in the focused workspace
            node_workspace = node.workspace()
            if node_workspace and node_workspace.name == workspace_name:
                # Check if the window is not on another workspace (like a floating window)
                # We need to ensure it actually belongs to the current workspace
                if not self._is_window_on_different_workspace(node, workspace_name):
                    self.clients.append(node)
        if len(self.clients) < 2:
            self.quit()
            return
        # Capture thumbnails, temporarily focusing each window if needed
        self.thumb_files = []
        for client in self.clients:
            focused_temporarily = False
            if client.id != focused_id:
                self.i3.command(f'[con_id={client.id}] focus')
                time.sleep(0.00001)  # Small delay for rendering
                focused_temporarily = True
            path = self._capture_thumbnail(client)
            if focused_temporarily:
                self.i3.command(f'[con_id={focused_id}] focus')
                time.sleep(0.00001)  # Delay to restore
            if path:
                self.thumb_files.append(path)
        # Create window
        self.window = Gtk.ApplicationWindow(application=self)
        self.window.set_title("Sway Window Switcher")
        self.window.set_default_size(300, 200)
        self.window.set_decorated(False)
        # Main box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        main_box.set_margin_top(20)
        main_box.set_margin_bottom(20)
        main_box.set_margin_start(20)
        main_box.set_margin_end(20)
        self.window.set_child(main_box)
        # Thumbnails horizontal box
        thumbs_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        thumbs_box.set_halign(Gtk.Align.CENTER)
        thumbs_box.set_valign(Gtk.Align.CENTER)
        main_box.append(thumbs_box)
        # CSS to highlight the selected window
        css = Gtk.CssProvider()
        css.load_from_data(b"""
            .selected {
                border: 4px solid #4CAF50;
                border-radius: 8px;
                background-color: rgba(76, 175, 80, 0.1);
                padding: 6px;
            }
            .thumb-label {
                color: white;
                font-size: 14px;
                margin-top: 6px;
            }
""")
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        # Create items
        self.items = []
        self.index = 1  # Start on the next one ("already switched once" effect)
        for i, path in enumerate(self.thumb_files):
            item_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
            item_box.set_halign(Gtk.Align.CENTER)
            img = Gtk.Image.new_from_file(path)
            img.set_pixel_size(self.thumb_size[0])
            item_box.append(img)
            label = Gtk.Label(label=self.clients[i].name or "Untitled")
            label.add_css_class("thumb-label")
            label.set_ellipsize(3)  # Pango.EllipsizeMode.END
            label.set_max_width_chars(25)
            item_box.append(label)
            thumbs_box.append(item_box)
            self.items.append(item_box)
            if i == self.index:
                item_box.add_css_class("selected")
        # Keyboard controller
        key_controller = Gtk.EventControllerKey.new()
        key_controller.connect("key-pressed", self._on_key_pressed)
        key_controller.connect("key-released", self._on_key_released)
        self.window.add_controller(key_controller)
        # Show window
        self.window.present()
        # Position and configure as floating (via swaymsg)
        GLib.timeout_add(80, self._position_and_configure_window)

    def _is_window_on_different_workspace(self, node, current_workspace_name):
        """Checks if a floating window actually belongs to another workspace"""
        # Floating windows may have a different workspace in i3ipc
        # We need to check if the window's parent is in the current workspace
        parent = node.parent
        while parent and not parent.type == "workspace":
            parent = parent.parent
        if parent and parent.type == "workspace":
            return parent.name != current_workspace_name
        return False

    def _capture_thumbnail(self, client):
        rect = client.rect
        geo = f"{rect.x},{rect.y} {rect.width}x{rect.height}"
        fd, path = tempfile.mkstemp(suffix='.png')
        os.close(fd)
        try:
            subprocess.run(['grim', '-g', geo, path], check=True, capture_output=True)
            img = Image.open(path)
            img.thumbnail(self.thumb_size, Image.Resampling.LANCZOS)
            img.save(path)
            return path
        except Exception as e:
            print("Error capturing thumbnail:", e)
            return None

    def _position_and_configure_window(self):
        if not self.window:
            return False
        # Make floating and center
        subprocess.run(['swaymsg', '[title="Sway Window Switcher"] floating enable'], capture_output=True)
        subprocess.run(['swaymsg', '[title="Sway Window Switcher"] border none'], capture_output=True)
        # Try to center (may need adjustment depending on resolution)
        subprocess.run(['swaymsg', '[title="Sway Window Switcher"] move position center'], capture_output=True)
        # Approximate size based on number of windows
        w = min(len(self.clients) * (self.thumb_size[0] + 40), 1400)
        h = self.thumb_size[1] + 120
        subprocess.run(['swaymsg', f'[title="Sway Window Switcher"] resize set {w} {h}'], capture_output=True)
        return False

    def _on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Tab:
            shift = bool(state & Gdk.ModifierType.SHIFT_MASK)
            direction = -1 if shift else 1
            self._cycle(direction)
            return True
        if keyval == Gdk.KEY_Left:
            self._cycle(-1)
            return True
        if keyval == Gdk.KEY_Right:
            self._cycle(1)
            return True
        # Confirmation with Enter
        if keyval in (Gdk.KEY_Return, Gdk.KEY_KP_Enter):
            self._select_and_close()
            return True
        return False

    def _on_key_released(self, controller, keyval, keycode, state):
        if keyval in (Gdk.KEY_Alt_L, Gdk.KEY_Alt_R):
            self._select_and_close()
            return True
        return False

    def _cycle(self, direction):
        if not self.items:
            return
        self.items[self.index].remove_css_class("selected")
        self.index = (self.index + direction) % len(self.items)
        self.items[self.index].add_css_class("selected")

    def _select_and_close(self):
        if not self.clients or self.index >= len(self.clients):
            self.quit()
            return
        selected_id = self.clients[self.index].id
        # IMPORTANT: Only focus the window without changing its state
        # We use 'focus' without any additional commands that change the state
        self.i3.command(f'[con_id={selected_id}] focus')
        # Cleanup
        for path in self.thumb_files:
            try:
                if path and os.path.exists(path):
                    os.unlink(path)
            except:
                pass
        self.quit()

    def do_shutdown(self):
        # Extra cleanup if needed
        Gtk.Application.do_shutdown(self)

if __name__ == "__main__":
    # Check if an instance is already running
    if check_running_instance():
        print("An instance of the switcher is already running. Exiting...")
        sys.exit(0)
    app = SwaySwitcher()
    app.run()