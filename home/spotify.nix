{ config, pkgs, lib, ... }:

(lib.mkIf config.misha.desktopApps.spotify.enable {
  # services.librespot = {
  #   enable = true;
  #   settings = {
  #     name = "${hostname} (librespot)";
  #     cache = "${config.home.homeDirectory}/.cache/librespot";
  #     enable-oauth = true;
  #     oauth-port = "0";
  #     backend = "pulseaudio";
  #     cache-size-limit = "1G";
  #     device-type = "computer";
  #   };
  # };
  home.packages = [ pkgs.spotify ];
})
