{
  config,
  pkgs,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.enable {
  services.flatpak = {
    enable = true;
  };
  services.flatpak.packages = lib.optional config.misha.desktop.gaming.enable "com.heroicgameslauncher.hgl";
  home.packages = [ pkgs.flatpak ];
  xdg.systemDirs.data = [ "$HOME/.local/share/flatpak/exports/share" ];
})
