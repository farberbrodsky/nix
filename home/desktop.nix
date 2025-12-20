{ config, pkgs, lib, ... }:

{
  gtk.cursorTheme = {
    package = pkgs.numix-cursor-theme;
  };

  home.packages = with pkgs; [
    kdePackages.dolphin
    keepassxc
  ];

  misha.desktop.keyboardShortcuts = {
    "Mod4+z" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
    "Mod4+b" = "${pkgs.firefox}/bin/firefox";
  };
}
