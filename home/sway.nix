{
  config,
  pkgs,
  lib,
  ...
}:

let
  workspaceNumbers = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "10"
  ];
  workspaceButtons = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "0"
  ];
  volumeDown = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  volumeUp = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
  mediaNext = "${pkgs.playerctl}/bin/playerctl next";
  mediaPrev = "${pkgs.playerctl}/bin/playerctl previous";
  mediaPlay = "${pkgs.playerctl}/bin/playerctl play";
  mediaPause = "${pkgs.playerctl}/bin/playerctl pause";
  mediaPlayPause = "${pkgs.playerctl}/bin/playerctl play-pause";
  clearNotifications = "makoctl dismiss -a";
  brightnessDown = "${pkgs.brightnessctl}/bin/brightnessctl -n1 s -- \"-5%\"";
  brightnessUp = "${pkgs.brightnessctl}/bin/brightnessctl -n1 s -- \"+5%\"";
  screenshot = "flameshot gui";
  ex = c: "exec --no-startup-id ${c}";
  # Context-aware Mod+Return in the same directory as the current window:
  # - "open terminal here" for dolphin (using the binding made for the "open_terminal_here" action)
  # - "Ctrl+Alt+Shift+N" for kitty (configured in kitty.conf)
  # - launch kitty otherwise
  terminalHere = pkgs.writeShellScript "terminal-here" ''
    app=""
    read -r app < "$HOME/.cache/sway-focused-app" 2>/dev/null || true
    case "$app" in
      org.kde.dolphin) exec ${pkgs.wtype}/bin/wtype -M ctrl -k Return -m ctrl ;;
      kitty) exec ${pkgs.wtype}/bin/wtype -M ctrl -M alt -M shift -k n -m shift -m alt -m ctrl ;;
      *) exec ${pkgs.kitty}/bin/kitty ;;
    esac
  '';
  # similar, but for dolphin in the current directory
  filesHere = pkgs.writeShellScript "files-here" ''
    app=""
    read -r app < "$HOME/.cache/sway-focused-app" 2>/dev/null || true
    case "$app" in
      org.kde.dolphin) exec ${pkgs.wtype}/bin/wtype -M ctrl -k n -m ctrl ;;
      kitty) exec ${pkgs.wtype}/bin/wtype -M ctrl -M alt -M shift -k z -m shift -m alt -m ctrl ;;
      *) exec ${pkgs.kdePackages.dolphin}/bin/dolphin ;;
    esac
  '';
  swayKeys = [
    {
      key = "mod+n";
      desc = "volume down";
      bind = "${ex volumeDown}";
    }
    {
      key = "mod+m";
      desc = "volume up";
      bind = "${ex volumeUp}";
    }
    {
      key = "mod+p";
      desc = "play/pause";
      bind = "${ex mediaPlayPause}";
    }
    {
      key = "mod+bracketleft";
      desc = "previous track";
      bind = "${ex mediaPrev}";
    }
    {
      key = "mod+bracketright";
      desc = "next track";
      bind = "${ex mediaNext}";
    }
    {
      key = "mod+c";
      desc = "clear notifications";
      bind = "${ex clearNotifications}";
    }
    {
      key = "mod+Shift+<";
      keycode = "mod+Shift+60";
      desc = "move workspace to output left";
      bind = "move workspace to output left";
    }
    {
      key = "mod+Shift+>";
      keycode = "mod+Shift+59";
      desc = "move workspace to output right";
      bind = "move workspace to output right";
    }
    {
      key = "mod+Shift+s";
      desc = "screenshot";
      bind = "${ex screenshot}";
    }
    {
      key = "mod+Shift+m";
      desc = "show spotify";
      bind = "[class=\"Spotify\"] scratchpad show";
    }
    {
      key = "mod+Shift+/";
      keycode = "mod+Shift+61";
      desc = "show this menu";
      bind = "${ex "mishakeys"}";
    }
    {
      key = "mod+z";
      desc = "open file manager";
      bind = "exec ${filesHere}";
    }
  ];
  swayKeyMap = lib.listToAttrs (map (e: lib.attrsets.nameValuePair e.key e.desc) swayKeys);
  swayKeysToBind = lib.listToAttrs (
    map (e: lib.attrsets.nameValuePair (builtins.replaceStrings [ "mod+" ] [ "Mod4+" ] e.key) e.bind) (
      builtins.filter (e: !(e ? keycode)) swayKeys
    )
  );
  swayKeysToKeycodeBind = lib.listToAttrs (
    map (
      e: lib.attrsets.nameValuePair (builtins.replaceStrings [ "mod+" ] [ "Mod4+" ] e.keycode) e.bind
    ) (builtins.filter (e: e ? keycode) swayKeys)
  );
in
{
  imports = [ ./sway/swaylock.nix ];
  config = lib.mkIf config.misha.desktop.enable {
    home.packages = with pkgs; [
      way-displays
      flameshot
      wtype # synthetic key injection (virtual-keyboard protocol) for context-aware bindings
    ];
    misha.desktop.keyboardShortcutsMod = "Mod4";
    misha.keys.sway = swayKeyMap;

    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures.gtk = true;
      extraConfig = "seat seat0 xcursor_theme Quintom_Ink 24";
      config = rec {
        input = {
          "*" = {
            xkb_layout = "us,il";
            xkb_options = "grp:win_space_toggle";
          };
        };
        terminal = "${pkgs.kitty}/bin/kitty";
        menu = "${pkgs.wofi}/bin/wofi --show drun -t ${pkgs.kitty}/bin/kitty";
        modifier = config.misha.desktop.keyboardShortcutsMod;
        bars = [ { command = "waybar"; } ];
        modes = { };
        startup = [
          {
            command = "${pkgs.way-displays}/bin/way-displays > /tmp/way-displays.\${XDG_VTNR}.\${USER}.log 2>&1 &";
            always = false;
          }
          {
            command = "mako";
            always = false;
          }
        ];
        fonts = {
          names = [ "JetBrainsMono Nerd Font" ];
          size = 10.0;
        };
        colors =
          let
            C = import ./colors.nix;
            B = C.darkBackground;
            D = C.darkMuted;
          in
          {
            focused = {
              border = D.blue;
              background = D.blue;
              text = builtins.elemAt B 0;
              indicator = D.purple;
              childBorder = builtins.elemAt B 0;
            };
            focusedInactive = {
              border = builtins.elemAt B 0;
              background = builtins.elemAt B 0;
              text = D.yellow;
              indicator = D.purple;
              childBorder = builtins.elemAt B 0;
            };
            unfocused = {
              border = builtins.elemAt B 0;
              background = builtins.elemAt B 0;
              text = D.yellow;
              indicator = D.purple;
              childBorder = builtins.elemAt B 0;
            };
            urgent = {
              border = D.red;
              background = D.red;
              text = "#ffffff";
              indicator = D.red;
              childBorder = D.red;
            };
          };
        bindkeysToCode = true;
        keybindings = lib.attrsets.mergeAttrsList [
          # workspace list
          (lib.attrsets.mergeAttrsList (
            map (ws: {
              "${modifier}+${ws.fst}" = "workspace number ${ws.snd}";
              "${modifier}+Shift+${ws.fst}" = "move container to workspace number ${ws.snd}";
            }) (lib.lists.zipLists workspaceButtons workspaceNumbers)
          ))

          (lib.attrsets.concatMapAttrs
            (key: direction: {
              "${modifier}+${key}" = "focus ${direction}";
              "${modifier}+Shift+${key}" = "move ${direction}";
              "${modifier}+Ctrl+${key}" =
                let
                  resizes = {
                    left = "shrink width";
                    down = "grow height";
                    up = "shrink height";
                    right = "grow width";
                  };
                in
                "resize ${resizes.${direction}} 10px or 10 ppt";
            })
            {
              h = "left";
              j = "down";
              k = "up";
              l = "right";
              Left = "left";
              Down = "down";
              Up = "up";
              Right = "right";
            }
          )

          {
            "${modifier}+Return" = "exec ${terminalHere}";
            "${modifier}+Shift+Return" = "exec ${pkgs.kitty}/bin/kitty";
            "${modifier}+Shift+c" = "kill";
            "${modifier}+d" = "exec ${menu}";

            "${modifier}+v" = "split h";
            "${modifier}+s" = "split v";
            "${modifier}+f" = "fullscreen toggle";
            "${modifier}+w" = "layout tabbed";
            "${modifier}+t" = "split none; split v; layout tabbed";
            "${modifier}+e" = "layout toggle split";
            "${modifier}+Shift+space" = "floating toggle";
            "${modifier}+space" = "focus mode_toggle";
            "${modifier}+Shift+minus" = "move scratchpad";
            "${modifier}+minus" = "scratchpad show";
            "${modifier}+a" = "focus parent";

            "XF86MonBrightnessDown" = "${ex brightnessDown}";
            "XF86MonBrightnessUp" = "${ex brightnessUp}";

            # not sure wireplumber is the best for this but eh
            "XF86AudioLowerVolume" = "${ex volumeDown}";
            "XF86AudioRaiseVolume" = "${ex volumeUp}";

            "XF86AudioNext" = "${ex mediaNext}";
            "XF86AudioPrev" = "${ex mediaPrev}";
            "XF86AudioPlay" = "${ex mediaPlay}";
            "XF86AudioPause" = "${ex mediaPause}";

            "${modifier}+Shift+r" = "reload";
            "${modifier}+Shift+e" =
              "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
          }

          (lib.attrsets.mapAttrs (_k: v: "exec ${v}") config.misha.desktop.keyboardShortcuts)
          swayKeysToBind
        ];
        keycodebindings = swayKeysToKeycodeBind;
        window.commands = [
          {
            command = "move scratchpad";
            criteria.class = "Spotify";
          }
        ];
      };
    };

    systemd.user.services.sway-focus-watch = {
      Unit = {
        Description = "Track focused sway window for Mod+Return dispatch";
        PartOf = [ "sway-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.python3}/bin/python3 -u ${
          pkgs.replaceVars ./sway/focus-watch.py {
            swaymsg = "${pkgs.sway}/bin/swaymsg";
          }
        }";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };

    services.mako =
      let
        C = import ./colors.nix;
      in
      {
        enable = true;
        settings = {
          actions = 1;
          history = 1;
          max-history = 5;
          on-button-left = "invoke-default-action";
          on-button-middle = "dismiss-group";
          on-button-right = "dismiss";
          on-touch = "invoke-default-action";
          font = "JetBrainsMono Nerd Font 10";

          anchor = "top-right";
          background-color = builtins.elemAt C.lightBackground 3;
          text-color = builtins.elemAt C.lightForeground 3;
          border-color = builtins.elemAt C.lightBackground 5;
          progress-color = "over ${C.lightStrong.aqua}";
          border-radius = 8;
        };
        extraConfig = ''
          [app-name="Spotify"]
          default-timeout=4000
          ignore-timeout=1
        '';
      };

    programs.waybar.enable = true;
    programs.waybar.settings = {
      mainBar = import ./sway/waybar.nix;
    };
    programs.waybar.style = lib.fileContents ./sway/waybar.css;
    xdg.configFile."waybar/waybar_power_menu.xml".source = ./sway/waybar_power_menu.xml;

    programs.workstyle = {
      enable = true;
      settings = {
        kitty = "";
        firefox = "";
        chrome = "";
        chromium = "";
        dolphin = "";
        keepassxc = "";
        code = "";
        steam = "";
        heroic = " ";
        spotify = "";
        other = {
          fallback_icon = "";
          deduplicate_icons = false;
          separator = ": ";
        };
      };
      systemd.enable = true;
      systemd.target = "sway-session.target";
    };

    programs.wofi = {
      enable = true;
      settings = {
        width = 600;
        height = 500;
        location = "center";
        allow_images = "true";
        image_size = 40;
        insensitive = true;
      };
      style = ''
        window {
        margin: 0px;
        border: 1px solid #928374;
        background-color: #282828;
        }

        #input {
        margin: 5px;
        border: none;
        color: #ebdbb2;
        background-color: #1d2021;
        }

        #inner-box {
        margin: 5px;
        border: none;
        background-color: #282828;
        }

        #outer-box {
        margin: 5px;
        border: none;
        background-color: #282828;
        }

        #scroll {
        margin: 0px;
        border: none;
        }

        #text {
        margin: 5px;
        border: none;
        color: #ebdbb2;
        }

        #entry:selected {
        background-color: #1d2021;
        }
      '';
    };

    services.wl-clip-persist = {
      enable = true;
      extraOptions = [
        "--ignore-event-on-error"
        "--all-mime-type-regex"
        "(?i)^(?!x-kde-passwordManagerHint).+"
        "--selection-size-limit"
        "1048576"
      ];
      systemdTargets = [ "sway-session.target" ];
    };
  };
}
