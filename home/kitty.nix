{ config, pkgs, ... }:

{
  home.packages = [ pkgs.kitty ];
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;
}
