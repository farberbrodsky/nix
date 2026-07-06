# Agent Guide: keyboard-shortcuts (mishakeys)

## Purpose

A graphical launcher (`mishakeys`) that reads `~/.config/mishakeys.json` and feeds all shortcuts into `wofi` (or `dmenu` as fallback) for fuzzy search. Selecting a shortcut copies its keybinding to the clipboard.

## Key Files

| Path | Role |
|------|------|
| `/persist/nix/home/keyboard-shortcuts.nix` | Nix module: defines `misha.keys` option, generates JSON, builds package |
| `pyproject.toml` | Python metadata, entry point `mishakeys = "keyboard_shortcuts:main_cli"` |
| `keyboard_shortcuts/__init__.py` | Launcher implementation |

## How Shortcuts Are Defined

Edit `keyboard-shortcuts.nix`, add entries under the `keys` attribute set:

```nix
keys = {
  sway = {
    "mod+m"   = "volume up";
    "mod+n" = "volume down";
  };
  firefox = {
    "ctrl+shift+i" = "open devtools";
  };
};
```

Top-level keys are **categories** (sway, firefox, terminal, etc). Each maps **keybinding → description**.

After editing: run `nix fmt` from `/persist/nix`, notify user to apply with `M-hm switch`.

## JSON Schema

The generated `~/.config/mishakeys.json` is `{ category: { keybinding: description } }`.

The launcher reads this at runtime. Never edit it directly — it's overwritten on rebuild.

## Launcher Implementation

Installed as `mishakeys`. Behaviour:

1. Read `~/.config/mishakeys.json`.
2. Build menu lines: `"description :: keybinding"`.
3. Pipe into `wofi --dmenu` (fallback to `dmenu` if wofi absent).
4. On selection, extract the keybinding (after ` :: `) and print it to stdout.
5. Graceful error handling if file missing, malformed, or launcher/clipboard tool absent.
6. **stdlib only** — no external PyPI deps. `wofi` and `wl-clipboard` are provided as Nix build inputs.

### Quick iteration (no Nix):

```bash
cd /persist/nix/home/keyboard-shortcuts
python -m keyboard_shortcuts
```

Requires `wofi` and `wl-copy` on `PATH` to work fully.

## Change Checklist

1. Edit the right file (shortcuts → `keyboard-shortcuts.nix`, code → `__init__.py`).
2. Run `nix fmt` from `/persist/nix`.
3. Notify the user to apply with `M-hm switch`.

## Anti-Patterns

- **Don't edit `~/.config/mishakeys.json` directly** — auto-generated, overwritten on rebuild.
- **Don't add external PyPI deps** — keep stdlib-only to keep Nix closure light.
- **Don't make the tool write the JSON** — config is managed through Nix, not at runtime.