{
  inputs = {
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixneovimplugins.url = github:NixNeovim/NixNeovimPlugins;
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # NOTE: 'nixos' is the default hostname
      nixos = nixpkgs.lib.nixosSystem {
        modules = [ ./configuration.nix ];
      };
    };
    homeConfigurations = {
      misha = home-manager.lib.homeManagerConfiguration {
        # TODO improve
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
	  ./home.nix
          { nixpkgs.overlays = [ inputs.nixneovimplugins.overlays.default ]; }
	];
      };
    };
  };
}

