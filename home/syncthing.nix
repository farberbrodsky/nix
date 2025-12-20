{ config, pkgs, lib, ... }:

{
  options.misha.syncthing.enable = lib.mkEnableOption "misha syncthing";

  config = {
    services.syncthing = lib.mkIf config.misha.syncthing.enable {
      enable = true;
    };
  };
}
