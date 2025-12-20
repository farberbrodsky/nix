{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    unzip
    ripgrep
  ];
  programs.bash.enable = true;
  programs.bash.initExtra = builtins.readFile ./dotfiles/bashprompt.sh;
  home.file.".gitstatus.sh".source = ./dotfiles/gitstatus.sh;
}
