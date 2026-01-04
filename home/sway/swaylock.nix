{
  config,
  utils,
  pkgs,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.swaylock.enable {
  programs.swaylock = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font";
      font-size = 24;
    };
  };
})
