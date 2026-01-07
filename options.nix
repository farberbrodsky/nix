{
  config,
  my-utils,
  lib,
  ...
}:

{
  options.misha =
    with lib;
    let
      desktopDefault = my-utils.mkDefaultEnableOption config.misha.desktop.enable;
      desktopPersonalDefault = my-utils.mkDefaultEnableOption config.misha.desktop.personal.enable;
    in
    {
      # Normal desktop stuff
      desktop.enable = mkEnableOption "desktop";
      desktop.laptop.enable = mkEnableOption "laptop";

      # Things that require personal credentials
      desktop.personal.enable = mkEnableOption "desktop";

      # Gamer moment
      desktop.gaming.enable = mkEnableOption "gaming";

      # To add keyboard shortcuts to sway
      desktop.keyboardShortcuts = mkOption {
        type = lib.types.attrsOf (lib.types.str);
        default = { };
      };

      desktop.default.browser = mkOption {
        default = "firefox.desktop";
        example = true;
        description = "pick your poison";
        type = lib.types.str;
      };

      desktop.swaylock.enable = desktopDefault "swaylock";

      desktopApps.chromium.enable = desktopDefault "chromium";
      desktopApps.spotify.enable = desktopPersonalDefault "spotify";

      syncthing.enable = desktopPersonalDefault "syncthing";

      system.btrfsImpermanence.enable = mkEnableOption "btrfs impermanence";
    };
}
