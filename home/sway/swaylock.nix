{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.misha.swaylockGlobals = {
    powerMenuScript = lib.mkOption { type = lib.types.str; };
  };
  config = lib.mkIf config.misha.desktop.swaylock.enable (
    lib.mkMerge [
      {
        misha.swaylockGlobals.powerMenuScript =
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
      }
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
            events = {
              "before-sleep" = (display "off") + "; " + lock;
              "after-resume" = display "on";
              inherit lock;
              unlock = display "on";
            };
          };
      }
      {
        # power menu on mod+backslash
        misha.desktop.keyboardShortcuts."${config.misha.desktop.keyboardShortcutsMod}+backslash" =
          config.misha.swaylockGlobals.powerMenuScript;
      }
      (lib.mkIf config.misha.desktop.laptop.enable {
        # power menu on power key
        # thoughts & prayers (I invented this command)
        wayland.windowManager.sway.config.startup = [
          {
            always = false;
            command = "systemd-inhibit --what handle-power-key swaymsg -t subscribe '[\"shutdown\"]'";
          }
        ];
        misha.desktop.keyboardShortcuts."XF86PowerOff" = config.misha.swaylockGlobals.powerMenuScript;
      })
    ]
  );
}
