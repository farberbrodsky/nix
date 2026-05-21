{
  config,
  pkgs,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.enable {
  programs.dconf.enable = true;
  services.dbus.enable = true;
  services.blueman.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.polkit.enable = true;

  services.greetd = lib.mkMerge [
    { enable = true; }
    (lib.mkIf config.misha.desktop.autologin.enable {
      settings = rec {
        initial_session = {
          command = "sway";
          inherit (config.misha.desktop.autologin) user;
        };
        default_session = initial_session;
      };
    })
    (lib.mkIf (!config.misha.desktop.autologin.enable) {
      useTextGreeter = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
          user = "greeter";
        };
      };
    })
  ];
  users.users.greeter = { };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  security.pam.services = lib.mkIf config.misha.desktop.swaylock.enable { swaylock = { }; };
})
