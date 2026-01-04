{
  pkgs,
  config,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.swaylock.enable (
  lib.mkMerge [
    {
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
              command = lock;
            }
            {
              event = "unlock";
              command = display "on";
            }
          ];
        };
    }
    (lib.mkIf config.misha.desktop.laptop.enable {
      # thoughts & prayers (I invented this command)
      wayland.windowManager.sway.config.startup = [
        {
          always = false;
          command = "systemd-inhibit --what handle-power-key swaymsg -t subscribe '[\"shutdown\"]'";
        }
      ];
      misha.desktop.keyboardShortcuts."XF86PowerOff" =
        let
          shellApplication = pkgs.writeShellApplication {
            name = "power-menu";
            runtimeInputs = [
              pkgs.systemd
              pkgs.wofi
              pkgs.sway
            ];
            text = builtins.readFile ./power-menu.sh;
          };
        in
        "${shellApplication}/bin/power-menu";
    })
  ]
))
