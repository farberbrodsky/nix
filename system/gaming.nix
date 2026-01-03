{
  config,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.gaming.enable {
  # literally magic
  programs.steam.enable = true;
})
