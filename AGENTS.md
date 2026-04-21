# Agent Guide: NixOS Configuration

This directory contains the NixOS and Home Manager configuration for this system.

## Important Paths

- **Root:** `/persist/nix`
- **Entry Point:** `flake.nix`
- **NixOS Config:** `configuration.nix` (shared), `system/` (modules)
- **Home Manager Config:** `home.nix` (shared), `home/` (modules)
- **Host Specifics:** `hosts/`
- **Custom Options:** `options.nix` (defines `misha.*` options)
- **Custom Packages:** `pkgs/`
- **Overlays:** `overlays/`

## Workflows

### 1. Proposing Changes

Agents are **not allowed** to apply changes themselves (e.g., they should not run `switch` or `boot` commands). Instead, they should:
- Edit the relevant `.nix` files.
- Run `nix fmt` to ensure correct formatting.
- Inform the user that the changes are ready to be applied.

The user can then apply the changes using:
- **NixOS System:** `M-nixos-rebuild switch`
- **Home Manager:** `M-hm switch`

### 2. Adding Packages

- **User-specific (Preferred):** Add to `home.packages` in `home.nix` or a relevant module in `home/`. **Almost all packages should be installed via Home Manager.**
- **System-wide:** Only add to `environment.systemPackages` in `configuration.nix` if strictly necessary for all users or system operation.

#### Missing Packages

If a package is missing from the current `nixpkgs` (e.g., only in unstable or external repositories):
- **NPM Packages:**
    1. Add the package name to `/persist/nix/pkgs/node/node-packages.json`.
    2. Run `M-update-node` to regenerate the Nix files.
    3. Use it via `pkgs.extra-node.$packageName`.
- **Other Packages:**
    - **Do not** be proactive in adding new flake inputs or changing channels.
    - **Prefer** integrating a copy of the package's definition into the `pkgs/` directory and calling it from `pkgs/default.nix`.
    - Keep the configuration clean.

### 3. Modifying Configuration

- Most configuration is modularized. Check `configuration.nix` and `home.nix` imports to find where a specific setting belongs.
- If you add a new `.nix` file in `system/` or `home/`, remember to add it to the `imports` list in `configuration.nix` or `home.nix` respectively.

### 4. Custom Options (`misha.*`)

We use a custom `misha` options tree defined in `options.nix`.
- Check `options.nix` to see available toggles (e.g., `misha.desktop.enable`).
- Host-specific overrides for these options are located in `hosts/default.nix`.

### 5. Searching for Options and Packages

There are several ways to search for settings:

#### Local Search (`M-optnix-*`)
Use the helper scripts for fast local searches against the current configuration:
- `M-optnix-nixos <query>`
- `M-optnix-hm <query>`
- **Agent Tip:** Use `-n` (non-interactive) and `-j` (JSON) flags: `M-optnix-hm -n -j programs.firefox.enable`

#### MCP Search (`nixos` server)
The `nixos` MCP server provides tools for searching upstream packages and options:
- `nixos_nixos_search`: Search packages, options, programs, or flakes.
  - Args: `query` (required), `search_type` (default: "packages")
- `nixos_home_manager_search`: Search Home Manager options.
  - Args: `query` (required)
- `nixos_nixos_info`: Get detailed info about a specific NixOS package or option.
  - Args: `name` (required), `type` (default: "package")
- `nixos_home_manager_info`: Get detailed information about a specific Home Manager option.
  - Args: `name` (required)

Example usage: 
`mcp({ tool: "nixos_home_manager_search", args: '{"query": "firefox"}' })`
`mcp({ tool: "nixos_home_manager_info", args: '{"name": "programs.firefox.enable"}' })`

## Change Checklist

Before considering a task complete, follow this checklist:

1.  **Search:** Use `M-optnix-*` or MCP tools to find the correct options.
2.  **Modularize:** Place the configuration in the most appropriate file (prefer `home/` for user settings).
3.  **Import:** If a new file was created, ensure it's added to the `imports` list in `configuration.nix` or `home.nix`.
4.  **Format:** Run `nix fmt` in the root directory (`/persist/nix`).
5.  **Notify:** Inform the user that the files have been updated and are ready for them to apply.

## Best Practices for Agents

- **No Self-Application:** Do not attempt to run `switch`, `boot`, or `rebuild` commands. Your role is to prepare the configuration files.
- **Atomic Changes:** Make small, incremental changes.
- **Modularity:** Prefer adding configuration to existing modules or creating new ones instead of cluttering `configuration.nix` or `home.nix`.
- **Impermanence:** This system uses BTRFS impermanence. Persistent data should be stored in `/persist`.
- **Formatting:** Run `nix fmt` before committing changes to ensure consistent formatting (using `treefmt`).

## Troubleshooting

- If a rebuild fails, read the error message carefully. Nix errors can be verbose but usually point to the exact file and line.
- Check `flake.lock` if there are issues with dependency versions. Use `nix flake update` to update inputs.
