{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) literalExpression mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.programs.workstyle;

  tomlFormat = pkgs.formats.toml { };

  configFile = tomlFormat.generate "config.toml" cfg.settings;

in
{
  options.programs.workstyle = {
    enable = mkEnableOption "Workstyle";

    package = lib.mkPackageOption pkgs "workstyle" { };

    systemd = {
      enable = mkEnableOption "Workstyle systemd integration";

      debug = mkEnableOption "Workstyle debug logs";

      target = mkOption {
        type = lib.types.str;
        default = config.wayland.systemd.target;
        defaultText = literalExpression "config.wayland.systemd.target";
        example = "sway-session.target";
        description = ''
          The systemd target that will automatically start the Workstyle service.

          When setting this value to `"sway-session.target"`,
          make sure to also enable {option}`wayland.windowManager.sway.systemd.enable`,
          otherwise the service may never be started.
        '';
      };
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = "Configuration for workstyle";
      example = literalExpression ''
        {
          # Config for workstyle
          # Format: "pattern" = "icon";
          # The pattern will be used to match against the application name, class_id or WM_CLASS.
          # The icon will be used to represent that application.
          # Note if multiple patterns are present in the same application name,
          # precedence is given in order of apparition in this file.
          kitty = "T";
          firefox = "B";
          other = {
            fallback_icon = "F";
            deduplicate_icons = false;
            separator = ": ";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [ (lib.hm.assertions.assertPlatform "programs.workstyle" pkgs lib.platforms.linux) ];

      home.packages = [ cfg.package ];
    }
    (mkIf (cfg.settings != { }) { xdg.configFile."workstyle/config.toml".source = configFile; })
    (mkIf cfg.systemd.enable {
      # See upstream: https://raw.githubusercontent.com/pierrechevalier83/workstyle/refs/heads/main/workstyle.service
      systemd.user.services.workstyle = {
        Unit = {
          Description = "workstyle autostart";
          BindsTo = [ cfg.systemd.target ];
          # This is not necessary: workstyle reloads the config file after every window event.
          # And yet, I think this is good future proofing.
          X-Restart-Triggers = mkIf (cfg.settings != { }) [ "${configFile}" ];
        };
        Service = {
          ExecStart = "${cfg.package}/bin/workstyle";
          Restart = "always";
          RestartSec = 3;
          Environment = mkIf cfg.systemd.debug "RUST_LOG=debug";
        };
        Install.WantedBy = [ cfg.systemd.target ];
      };
    })
  ]);
}
