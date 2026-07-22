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
      uid = mkOption {
        default = 1000;
        type = lib.types.int;
      };

      # Normal desktop stuff
      desktop.enable = mkEnableOption "desktop";
      desktop.laptop.enable = mkEnableOption "laptop";

      # Whether to do auto-login. Intended for systems with disk encryption.
      desktop.autologin.enable = mkEnableOption "autologin";
      # Username for auto-login
      desktop.autologin.user = mkOption {
        default = "misha";
        type = lib.types.str;
      };

      # Things that require personal credentials
      desktop.personal.enable = mkEnableOption "desktop";

      # Gamer moment
      desktop.gaming.enable = mkEnableOption "gaming";

      # To add keyboard shortcuts to sway
      desktop.keyboardShortcutsMod = mkOption {
        type = lib.types.str;
        default = "";
      };
      desktop.keyboardShortcuts = mkOption {
        type = lib.types.attrsOf lib.types.str;
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
      desktopApps.inkscape.enable = desktopPersonalDefault "inkscape";
      desktopApps.keepassxc.enable = desktopPersonalDefault "keepassxc";

      shell.llms.enable = desktopDefault "llms";

      syncthing.enable = desktopPersonalDefault "syncthing";

      system.btrfsImpermanence.enable = mkEnableOption "btrfs impermanence";
      system.btrfsImpermanence.mainUser.hashedPasswordFile = mkOption {
        default = null;
        type = lib.types.str;
      };
    };
}
