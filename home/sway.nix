{ config, pkgs, lib, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
    };
  };

  programs.waybar.enable = true;
  programs.waybar.settings = { mainBar = (import ./sway/waybar.nix); };
  programs.waybar.style = lib.fileContents ./sway/waybar.css;
}
