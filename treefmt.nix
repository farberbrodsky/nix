{
  projectRootFile = "flake.nix";

  programs = {
    deadnix.enable = true;
    statix.enable = true;
    keep-sorted.enable = true;
    nixfmt = {
      enable = true;
      strict = true;
    };
  };

  settings.excludes = [ "flake.lock" ];

  settings.formatter = {
    deadnix = {
      priority = 1;
    };

    statix = {
      priority = 2;
    };

    nixfmt = {
      priority = 3;
    };
  };
}
