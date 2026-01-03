{
  config,
  lib,
  pkgs,
  ...
}:

(lib.mkIf config.misha.desktop.enable {
  home.packages = [ pkgs.kitty ];
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;
})
