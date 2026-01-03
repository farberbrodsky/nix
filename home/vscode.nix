{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  programs.vscode = (
    lib.mkIf config.misha.desktop.enable {
      enable = true;
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          ms-python.python
          ms-vscode-remote.remote-ssh
        ];
        userSettings = {
          "workbench.colorTheme" = "Solarized Light";
          "workbench.secondarySideBar.defaultVisibility" = "hidden"; # Build with Agent bullshit
          "[nix].editor.tabSize" = 2;
        };
      };
    }
  );
}
