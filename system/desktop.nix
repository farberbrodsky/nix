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

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };
  users.users.greeter = { };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
})
