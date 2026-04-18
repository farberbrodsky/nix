# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  gruvbox-plus-icons-with-light = pkgs.callPackage ./gruvbox-plus-icons.nix { };
  pi-coding-agent = pkgs.callPackage ./pi-coding-agent.nix { };
}
