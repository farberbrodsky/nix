{ config, pkgs, inputs, lib, ... }:

{
  services.flatpak = {
    enable = true;
  };
  services.flatpak.packages = [
    "com.heroicgameslauncher.hgl"
  ];
  home.packages = [ pkgs.flatpak ];
  xdg.systemDirs.data = [ "$HOME/.local/share/flatpak/exports/share" ];
}
