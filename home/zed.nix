{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.zed-editor = lib.mkIf config.misha.desktop.enable {
    enable = true;
    extensions = [ "nix" ];
    extraPackages = with pkgs; [
      nixd
      (python3.withPackages (p: with p; [ basedpyright ruff ]))
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
  };
}
