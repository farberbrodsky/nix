{ config, pkgs, lib, ... }:

let
    workspace_names = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "10"];
    workspace_buttons = ["1" "2" "3" "4" "5" "6" "7" "8" "9" "0"];
in
{
  home.packages = with pkgs; [ way-displays ];

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    wrapperFeatures.gtk = true;
    extraConfig = "seat seat0 xcursor_theme Quintom_Ink 24";
    config = rec {
      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${pkgs.wofi}/bin/wofi --show drun -t ${pkgs.kitty}/bin/kitty";
      modifier = "Mod4";
      bars = [{ command = "waybar"; }];
      modes = {};
      startup = [
        { command = "${pkgs.way-displays}/bin/way-displays > /tmp/way-displays.\${XDG_VTNR}.\${USER}.log 2>&1 &"; always = false; }
        { command = "${pkgs.mako}/bin/mako"; always = false; }
      ];
      keybindings = lib.attrsets.mergeAttrsList [
        # workspace list
        (lib.attrsets.mergeAttrsList (map (ws: {
          "${modifier}+${ws.fst}" = "workspace ${ws.snd}";
          "${modifier}+Shift+${ws.fst}" = "move container to workspace ${ws.snd}";
        }) (lib.lists.zipLists workspace_buttons workspace_names)))

        (lib.attrsets.concatMapAttrs (key: direction: {
            "${modifier}+${key}" = "focus ${direction}";
            "${modifier}+Shift+${key}" = "move ${direction}";
            "${modifier}+Ctrl+${key}" = let resizes = {
              left = "shrink width";
              down = "grow height";
              up = "shrink height";
              right = "grow width";
            }; in "resize ${resizes.${direction}} 10px or 10 ppt";
          }) {
            h = "left";
            j = "down";
            k = "up";
            l = "right";
            Left = "left";
            Down = "down";
            Up = "up";
            Right = "right";
          })

        {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Shift+c" = "kill";
          "${modifier}+d" = "exec ${menu}";

          "${modifier}+v" = "split h";
          "${modifier}+s" = "split v";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";
          "${modifier}+a" = "focus parent";

          "${modifier}+Shift+greater" = "move workspace to output right";
          "${modifier}+Shift+less" = "move workspace to output left";

          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl s -- \"-5%\"";
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl s -- \"+5%\"";

          # volume control: ...
          # spotify: ...

          "${modifier}+Shift+r" = "reload";
          "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
        }

        (lib.attrsets.mapAttrs (k: v: "exec ${v}") config.misha.desktop.keyboardShortcuts)
      ];
    };
  };

  programs.waybar.enable = true;
  programs.waybar.settings = { mainBar = (import ./sway/waybar.nix); };
  programs.waybar.style = lib.fileContents ./sway/waybar.css;

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 500;
      location = "center";
      allow_images = "true";
      image_size = 40;
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
}
