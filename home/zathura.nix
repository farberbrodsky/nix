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
  xdg.mimeApps.defaultApplicationPackages = lib.mkIf config.misha.desktop.enable [
    config.programs.zathura.package
  ];
}
