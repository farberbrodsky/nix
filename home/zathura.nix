{ config, lib, ... }:

{
  programs.zathura = lib.mkIf config.misha.desktop.enable {
    enable = true;
    mappings = {
      "<A-z>" = "toggle_statusbar";
    };
    options = {
      selection-clipboard = "clipboard";
    };
  };
}
