{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  myOptions = (import inputs.my-sync).syncthing;
in
{
  services.syncthing = lib.mkIf config.misha.syncthing.enable {
    enable = true;
    settings.options = {
      relaysEnabled = true;
      urAccepted = 3; # accept usage reporting
    };
    settings.devices = myOptions.devices;
    settings.folders = myOptions.folders;
  };
}
