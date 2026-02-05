#!/usr/bin/env python3
# License: GPLv3
# Credits: Felipe Facundes

"""
Sway Window Switcher with notification
Behaves like sway's focus right / focus left + notification of the focused window
"""
import subprocess
import json
import sys


class SwayFastSwitcher:
    def __init__(self):
        self.show_preview = True

    def _get_focused_window_info(self):
        """Returns information about the currently focused window"""
        try:
            tree = json.loads(subprocess.run(
                ['swaymsg', '-t', 'get_tree'],
                capture_output=True, text=True, check=True
            ).stdout)

            def find_focused(node):
                if not isinstance(node, dict):
                    return None
                if node.get('focused'):
                    name = (node.get('name') or '').strip() or 'Untitled'
                    app_id = node.get('app_id') or ''
                    class_name = node.get('window_properties', {}).get('class', '')
                    return {
                        'name': name,
                        'app_id': app_id,
                        'class': class_name,
                        'id': node.get('id')
                    }
                for key in ['nodes', 'floating_nodes']:
                    if key in node:
                        for child in node[key]:
                            found = find_focused(child)
                            if found:
                                return found
                return None

            return find_focused(tree)
        except:
            return None

    def switch_window(self, direction='next'):
        if direction not in ('next', 'prev'):
            return

        sway_direction = 'right' if direction == 'next' else 'left'

        # Execute the native sway command
        subprocess.run(
            ['swaymsg', 'focus', sway_direction],
            capture_output=True, check=False
        )

        # Wait a very short moment for the focus to be updated
        # (generally 20-80ms is enough)
        import time
        time.sleep(0.06)

        # Get information about the window that was just focused
        info = self._get_focused_window_info()
        if not info:
            return

        if self.show_preview:
            try:
                icon = info['app_id'] or info['class'] or 'window'
                subprocess.run([
                    'notify-send',
                    '--app-name', 'Window Switcher',
                    '--icon', icon,
                    '--expire-time', '1400',
                    '--urgency', 'low',
                    f"→ {info['name']}"
                ], capture_output=True)
            except:
                pass

    def show_rofi_list(self):
        """List ALL windows (all workspaces)"""
        try:
            tree = json.loads(subprocess.run(
                ['swaymsg', '-t', 'get_tree'],
                capture_output=True, text=True, check=True
            ).stdout)

            windows = []
            def collect(node):
                if not isinstance(node, dict):
                    return
                if node.get('type') in ['con', 'floating_con'] and node.get('name'):
                    name = (node.get('name') or '').strip() or 'Untitled'
                    app_id = node.get('app_id') or ''
                    class_name = node.get('window_properties', {}).get('class', '')
                    skip = ['waybar', 'wofi', 'rofi', 'dmenu', 'swaync', 'swaylock']
                    if any(p in (app_id + name + class_name).lower() for p in skip):
                        return
                    windows.append({
                        'id': node['id'],
                        'name': name,
                        'app': app_id or class_name or '?',
                        'focused': node.get('focused', False)
                    })
                for k in ['nodes', 'floating_nodes']:
                    if k in node:
                        for c in node[k]:
                            collect(c)

            collect(tree)

            if not windows:
                return

            lines = []
            id_map = {}
            for i, w in enumerate(windows):
                prefix = "● " if w['focused'] else "  "
                line = f"{prefix}{w['name']}   <small>({w['app']})</small>"
                lines.append(line)
                id_map[i] = w['id']

            rofi_input = "\n".join(lines)

            result = subprocess.run(
                ['rofi', '-dmenu', '-i', '-p', 'Windows', '-format', 'i', '-no-custom'],
                input=rofi_input, text=True, capture_output=True, check=False
            )

            if result.returncode == 0 and result.stdout.strip():
                try:
                    idx = int(result.stdout.strip())
                    if idx in id_map:
                        subprocess.run(
                            ['swaymsg', f'[con_id={id_map[idx]}]', 'focus'],
                            capture_output=True
                        )
                except:
                    pass

        except Exception as e:
            print(f"Error listing windows: {e}", file=sys.stderr)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Sway Window Switcher")
    parser.add_argument('--next', action='store_true')
    parser.add_argument('--prev', action='store_true')
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--disable-preview', action='store_true')

    args = parser.parse_args()

    switcher = SwayFastSwitcher()

    if args.disable_preview:
        switcher.show_preview = False

    if args.list:
        switcher.show_rofi_list()
    elif args.prev:
        switcher.switch_window('prev')
    else:
        switcher.switch_window('next')   # default and --next


if __name__ == '__main__':
    main()