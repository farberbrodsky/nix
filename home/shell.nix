{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    unzip
    ripgrep
  ];
  programs.bash.enable = true;
  programs.bash.shellAliases."cfg" = "cd /persist/nix/";
  programs.bash.initExtra = builtins.readFile ./dotfiles/bashprompt.sh;
  home.file.".gitstatus.sh".source = ./dotfiles/gitstatus.sh;
}
