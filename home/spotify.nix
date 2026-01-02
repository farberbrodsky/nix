{ config, pkgs, lib, hostname, ... }:

(lib.mkIf config.misha.desktopApps.spotify.enable {
  services.librespot = {
    enable = true;
    settings = {
      name = "${hostname} (spotifyd)";
      cache = "${config.home.homeDirectory}/.cache/librespot";
      enable-oauth = true;
      oauth-port = "0";
      backend = "pulseaudio";
      cache-size-limit = "1G";
      device-type = "computer";
    };
  };
  home.packages = [ pkgs.spotify-qt ];
})
