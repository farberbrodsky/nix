{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.zed-editor = lib.mkIf config.misha.desktop.enable (lib.mkMerge [
    {
      enable = true;
      extensions = [
        "nix"
        "zig"
      ];
      extraPackages = with pkgs; [
        nixd
        (python3.withPackages (
          p: with p; [
            basedpyright
            ruff
            nil
          ]
        ))
      ];
      userSettings = {
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        vim_mode = true;
        icon_theme = "Zed (Default)";
        theme = {
          mode = "light";
          light = "Gruvbox Light";
          dark = "Gruvbox Dark";
        };
      };
    }
    (lib.mkIf config.misha.shell.llms.enable {
      extraPackages = with pkgs; [ extra-node.pi-acp ];
      userSettings = {
        agent_servers = {
          pi = {
            type = "custom";
            command = "pi-acp";
          };
        };
      };
    })
  ]);
}
