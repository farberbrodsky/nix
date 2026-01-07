{ options, config, pkgs, lib, inputs, hostname, ... }: let
  # Assume `optnix` is correctly instantiated.
  optnixLib = inputs.optnix.mkLib pkgs;
in {
  imports = [ inputs.optnix.homeModules.optnix ];
  programs.optnix = {
    enable = true;
    settings = {
      scopes = {
        home-manager = {
          description = "home-manager configuration for all systems";
          options-list-file = optnixLib.mkOptionsList {
            inherit options;
            transform = o:
              o
              // {
                name = lib.removePrefix "home-manager.users.${config.home.username}." o.name;
              };
          };
          evaluator = "nix eval /persist/nix#homeConfigurations.${config.home.username}@${hostname}.config.{{ .Option }}";
        };
      };
    };
  };
}

