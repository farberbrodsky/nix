import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


def menu(options: list[str], testing: bool = False) -> str | None:
    """Show a menu using wofi or dmenu.

    When *testing* is True, uses print/input instead of a graphical launcher
    so the tool can be exercised without a display server.

    Returns the selected item, or None if the user cancelled.
    """
    if not testing:
        launcher = shutil.which("wofi") or shutil.which("dmenu")

        if launcher is not None:
            input_str = "\n".join(options)

            launcher_name = Path(launcher).name
            if launcher_name == "wofi":
                args = [launcher, "--dmenu", "-p", "Shortcuts:"]
            else:
                args = [launcher, "-p", "Shortcuts:"]

            proc = subprocess.run(
                args,
                input=input_str,
                capture_output=True,
                text=True,
            )

            if proc.returncode != 0:
                return None
            selected = proc.stdout.strip()
            return selected or None

    # Fallback / testing: interactive stdin/stdout
    print("Select a shortcut (number, or enter text to fuzzy-search):")
    for i, opt in enumerate(options, 1):
        print(f"  {i}. {opt}")

    try:
        choice = input("> ").strip()
    except (EOFError, KeyboardInterrupt):
        return None

    if not choice:
        return None

    # Try numeric index first
    try:
        idx = int(choice) - 1
        if 0 <= idx < len(options):
            return options[idx]
    except ValueError:
        pass

    # Fall back to substring match
    for opt in options:
        if choice.lower() in opt.lower():
            return opt

    return None


def drill(data: dict | str, testing: bool) -> None:
    """Recursively navigate a nested dict via menu selections.

    - Keys of a dict become menu items (sorted).
    - If all values are strings (a leaf category with key→desc pairs),
      show formatted "desc :: key" lines and print the keybinding on selection.
    - If the selected value is a dict, recurse.
    - Returns when the user cancels at any level.
    """
    if isinstance(data, str):
        print(data)
        return

    if not data:
        return

    # Leaf category: values are strings, format as "desc :: key"
    if all(isinstance(v, str) for v in data.values()):
        options = sorted(f"{desc} :: {key}" for key, desc in data.items())
        chosen = menu(options, testing=testing)
        if chosen is None:
            return
        # Extract the keybinding (after " :: ")
        # print(chosen.split(" :: ", 1)[1] if " :: " in chosen else chosen)
        return

    # Category level: show category names
    options = sorted(data.keys())
    chosen = menu(options, testing=testing)
    if chosen is None:
        return

    drill(data[chosen], testing=testing)


def main_cli() -> None:
    parser = argparse.ArgumentParser(description="Browse keyboard shortcuts via wofi/dmenu.")
    parser.add_argument(
        "--testing",
        action="store_true",
        help="Use stdin/stdout instead of wofi/dmenu",
    )
    args = parser.parse_args()

    config_path = Path.home() / ".config" / "mishakeys.json"

    if not config_path.exists():
        print("mishakeys.json not found", file=sys.stderr)
        sys.exit(1)

    try:
        with open(config_path) as f:
            shortcuts = json.load(f)
    except json.JSONDecodeError:
        print("mishakeys.json is malformed", file=sys.stderr)
        sys.exit(1)

    drill(shortcuts, testing=args.testing)
