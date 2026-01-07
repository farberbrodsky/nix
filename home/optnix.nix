{
  options,
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}:
{
  imports = [ inputs.optnix.homeModules.optnix ];
  programs.optnix = {
    enable = true;
    settings = {
      scopes = {
        home-manager = {
          description = "home-manager configuration for this system";
          options-list-cmd = ''
            nix eval "/persist/nix#homeConfigurations.${config.home.username}@${hostname}" --json --apply 'input: let
              inherit (input) options pkgs;

              optionsList = builtins.filter
                (v: v.visible && !v.internal)
                (pkgs.lib.optionAttrSetToDocList options);
            in
              optionsList'
          '';
          # options-list-file = optnixLib.mkOptionsList {
          #   inherit options;
          #   transform = o:
          #     o
          #     // {
          #       name = lib.removePrefix "home-manager.users.${config.home.username}." o.name;
          #     };
          # };
          evaluator = "nix eval /persist/nix#homeConfigurations.${config.home.username}@${hostname}.config.{{ .Option }}";
        };
        nixos = {
          description = "nixos flake configuration for this system";
          options-list-cmd = ''
            nix eval "/persist/nix#nixosConfigurations.${hostname}" --json --apply 'input: let
              inherit (input) options pkgs;

              optionsList = builtins.filter
                (v: v.visible && !v.internal)
                (pkgs.lib.optionAttrSetToDocList options);
            in
              optionsList'
          '';
          evaluator = "nix eval /persist/nix#nixosConfigurations.${hostname}.config.{{ .Option }}";
        };
      };
    };
  };
}
