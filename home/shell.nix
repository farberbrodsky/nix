{ pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    unzip
    ripgrep
    gh
    python3
    jq
    tmux
    nodejs
    zoxide
    nurl
    python3Packages.markitdown
  ];
  programs.bash.enable = true;
  programs.bash.shellAliases."cfg" = "cd /persist/nix/";
  programs.bash.initExtra = ''
    eval "$(zoxide init bash)"
  ''
  + builtins.readFile ./dotfiles/bashprompt.sh;
  home.file.".gitstatus.sh".source = ./dotfiles/gitstatus.sh;
  services.ssh-agent.enable = true;
  programs.direnv.enable = true;
}
