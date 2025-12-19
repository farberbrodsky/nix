{ config, pkgs, lib, ... }:

{
  gtk.cursorTheme = {
    package = pkgs.numix-cursor-theme;
  };
}
