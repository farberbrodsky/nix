{
  pkgs,
  config,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.swaylock.enable {
  programs.swaylock = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font";
      font-size = 24;
    };
  };

  services.swayidle =
  let
    # Lock command
    lock = "${pkgs.swaylock}/bin/swaylock --daemonize";
    display = status: "${pkgs.sway}/bin/swaymsg 'output * power ${status}'";
  in
  {
    enable = true;
    extraArgs = [ "-w" ];
    timeouts = [
      {
        timeout = 300; # in seconds
        command = "${pkgs.libnotify}/bin/notify-send 'Locking in 10 seconds' -t 10000";
      }
      {
        timeout = 310;
        command = lock;
      }
      {
        timeout = 330;
        command = display "off";
        resumeCommand = display "on";
      }
      {
        timeout = 360;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = [
      {
        event = "before-sleep";
        # adding duplicated entries for the same event may not work
        command = (display "off") + "; " + lock;
      }
      {
        event = "after-resume";
        command = display "on";
      }
      {
        event = "lock";
        command = (display "off") + "; " + lock;
      }
      {
        event = "unlock";
        command = display "on";
      }
    ];
  };
})
