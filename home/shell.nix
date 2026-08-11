{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    unzip
    ripgrep
    gh
    python3
    jq
    tmux
    zoxide
    nurl
    python3Packages.markitdown
    eza
    squashfsTools
    btop
    bubblewrap
    gcc
  ];
  programs.bash.enable = true;
  programs.bash.shellAliases = {
    "cfg" = "cd /persist/nix/";
    "l" = "eza";
  };
  programs.bash.initExtra = ''
    export PATH="$PATH:$HOME/.npm-global/bin"
    eval "$(zoxide init bash)"
  ''
  + builtins.readFile ./dotfiles/bashprompt.sh;
  home.file.".gitstatus.sh".source = ./dotfiles/gitstatus.sh;
  services.ssh-agent.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  programs.lazyworktree = {
    enable = true;
    settings = {
      worktree_dir = "~/worktrees";
      auto_refresh = true;
      icon_set = "nerd-font-v3";
      theme = "gruvbox-light";
    };
  };
  programs.npm = {
    # includes nodejs
    enable = true;
    settings = {
      color = true;
      prefix = "${config.home.homeDirectory}/.npm-global";
    };
  };
}
