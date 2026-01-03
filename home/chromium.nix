{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.chromium = (
    lib.mkIf config.misha.desktopApps.chromium.enable {
      enable = true;
    }
  );
}
