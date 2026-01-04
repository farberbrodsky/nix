{
  inputs = {
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixneovimplugins.url = "github:NixNeovim/NixNeovimPlugins";
    impermanence.url = "github:nix-community/impermanence"; # has no inputs
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    my-sync.url = "path:/home/misha/Sync/sync.nix";
    my-sync.flake = false;
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      my-utils = (import ./utils inputs);
      hosts = (import ./hosts);
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Accessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # available through 'nix fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Custom packages and modifications, exported as overlays
      # Each overlay needs to be individually imported in configuration.nix and home.nix
      overlays = import ./overlays { inherit inputs; };

      # Stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = (
        nixpkgs.lib.mapAttrs (
          host: hostConfig:
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              inherit inputs;
              inherit my-utils;
            };
            modules = [
              (hostConfig.system // { misha = hostConfig.misha; })
              ./configuration.nix
            ];
          }
        ) hosts
      );

      homeConfigurations = nixpkgs.lib.mapAttrs' (
        host: hostConfig:
        nixpkgs.lib.nameValuePair "misha@${host}" (
          home-manager.lib.homeManagerConfiguration {
            # TODO improve
            pkgs = nixpkgs.legacyPackages.x86_64-linux;

            modules = [
              (hostConfig.home // { misha = hostConfig.misha; })
              ./home.nix
            ];
            extraSpecialArgs = {
              inherit inputs;
              inherit my-utils;
              hostname = "misha-gram";
            };
          }
        )
      ) hosts;
    };
}
