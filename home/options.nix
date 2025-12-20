{ config, pkgs, lib, ... }:
{
  options.misha = with lib; {
    syncthing.enable = mkEnableOption "syncthing";
  };
}
