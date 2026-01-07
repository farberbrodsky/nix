{
  misha-gram = {
    home = {
      home.username = "misha";
      home.homeDirectory = "/home/misha";
    };
    system = {
      imports = [ ./hardware-configuration/misha-gram.nix ];
      networking.hostName = "misha-gram";
    };
    # From: options.nix
    misha = {
      desktop.enable = true;
      desktop.laptop.enable = true;
      desktop.personal.enable = true;
      desktop.gaming.enable = true;
      system.btrfsImpermanence.enable = true;
    };
  };
}
