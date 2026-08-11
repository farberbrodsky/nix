#!/usr/bin/env python3
"""Track the focused sway window and cache its app_id/class.

The point is to remove IPC cost from the hot path: instead of every
Mod+Return press running `swaymsg -t get_tree | jq` (slow), a small
event-driven watcher keeps ~/.cache/sway-focused-app up to date, and the
keybinding only reads that file (a bash builtin, no fork).

@swaymsg@ is substituted by nix with an absolute store path.
"""

import json
import os
import subprocess

SWAYMSG = "@swaymsg@"
STATE = os.path.expanduser("~/.cache/sway-focused-app")


def app_id(node):
    """Best identifier for a container: wayland app_id, X11 class, else ''."""
    return node.get("app_id") or (node.get("window_properties") or {}).get("class") or ""


def write(state):
    try:
        with open(STATE, "w") as f:
            f.write(state + "\n")  # trailing newline: bash read returns 1 otherwise
    except OSError:
        pass


def first_focused(node):
    if node.get("focused"):
        return node
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        found = first_focused(child)
        if found:
            return found
    return None


def main():
    # Seed with the current focused view so state survives daemon restarts.
    try:
        tree = json.loads(
            subprocess.run([SWAYMSG, "-t", "get_tree"], capture_output=True, check=True).stdout
        )
        focused = first_focused(tree)
        if focused is not None:
            write(app_id(focused))
    except Exception:
        pass

    # Stream window events; subscribe exits if sway restarts, so loop forever.
    while True:
        try:
            proc = subprocess.Popen(
                [SWAYMSG, "-m", "-t", "subscribe", '["window"]'],
                stdout=subprocess.PIPE,
                text=True,
            )
            for line in proc.stdout:
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if event.get("change") == "focus":
                    write(app_id(event.get("container") or {}))
            proc.wait()
        except FileNotFoundError:
            pass
        except OSError:
            pass


if __name__ == "__main__":
    main()