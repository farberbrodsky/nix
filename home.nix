{ pkgs, inputs, ... }:

{
  imports = [
    ./options.nix
    ./home/chromium.nix
    ./home/desktop.nix
    ./home/flatpak.nix
    ./home/git.nix
    ./home/kitty.nix
    ./home/neovim.nix
    ./home/optnix.nix
    ./home/shell.nix
    ./home/spotify.nix
    ./home/sway.nix
    ./home/syncthing.nix
    ./home/vscode.nix
    ./home/zed.nix
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.self.homeManagerModules.workstyle
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      # You can also add overlays exported from other flakes:
      inputs.nixneovimplugins.overlays.default
      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];

    config.allowUnfree = true;
  };

  misha.desktop.enable = true;
  misha.desktop.personal.enable = true;

  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = (import ./home/identity.nix).username;
  home.homeDirectory = (import ./home/identity.nix).homeDirectory;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    (pkgs.writeShellScriptBin "M-hm" ''
      exec home-manager --flake /persist/nix "$@"
    '')
    (pkgs.writeShellScriptBin "M-nixos-rebuild" ''
      exec sudo nixos-rebuild --flake /persist/nix "$@"
    '')
    (pkgs.writeShellScriptBin "M-optnix-hm" ''
      exec optnix -s home-manager "$@"
    '')
    (pkgs.writeShellScriptBin "M-optnix-nixos" ''
      exec optnix -s nixos "$@"
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/misha/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.stateVersion = "25.05";
}
