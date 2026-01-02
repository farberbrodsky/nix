{ config, utils, lib, ... }:

{
  options.misha = with lib; let
    desktopDefault = utils.mkDefaultEnableOption config.misha.desktop.enable;
    desktopPersonalDefault = utils.mkDefaultEnableOption config.misha.desktop.personal.enable;
  in {
      # Normal desktop stuff
      desktop.enable = mkEnableOption "desktop";

      # Things that require personal credentials
      desktop.personal.enable = mkEnableOption "desktop";

      # To add keyboard shortcuts to sway
      desktop.keyboardShortcuts = mkOption {
        type = lib.types.attrsOf(lib.types.str);
        default = {};
      };

      desktop.default.browser = mkOption {
        default = "firefox.desktop";
        example = true;
        description = "pick your poison";
        type = lib.types.str;
      };

      desktopApps.chromium.enable = desktopDefault "chromium";
      desktopApps.spotify.enable = desktopPersonalDefault "spotify";

      syncthing.enable = desktopPersonalDefault "syncthing";
    };
}
