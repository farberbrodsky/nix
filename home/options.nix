{ config, pkgs, lib, ... }:
{
  options.misha = with lib; {
    syncthing.enable = mkEnableOption "syncthing";

    desktop.keyboardShortcuts = mkOption {
      type = lib.types.attrsOf(lib.types.str);
      default = {};
    };
  };
}
