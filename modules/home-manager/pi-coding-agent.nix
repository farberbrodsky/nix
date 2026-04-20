{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.pi-coding-agent;
  jsonFormat = pkgs.formats.json { };

in
{
  meta.maintainers = [ lib.maintainers.farberbrodsky ];

  options.programs.pi-coding-agent = {
    enable = lib.mkEnableOption "pi coding agent";

    package = lib.mkPackageOption pkgs "pi-coding-agent" { nullable = true; };

    offline = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Prevents package updates and automatic installation of tools.
        Corresponds to {env}`PI_OFFLINE`.
      '';
    };

    npmCommand = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = [
        "npm"
        "--prefix"
        "${config.home.homeDirectory}/.pi/npm/"
      ];
      description = ''
        Override for the npm command used by pi.
        Defaults to settings the global prefix to `~/.pi/npm/`, to solve pi's usage of `npm install -g`.
        Corresponds to {option}`programs.pi-coding-agent.settings.npmCommand`.
      '';
    };

    settings = lib.mkOption {
      inherit (jsonFormat) type;
      default = { };
      example = lib.literalExpression ''
        {
          defaultProvider = "anthropic";
          defaultModel = "claude-sonnet-4-20250514";
          theme = "dark";
          enableInstallTelemetry = false;
          packages = [ "npm:pi-subagents" ];
        }
      '';
      description = ''
        Configuration written to {file}`~/.pi/agent/settings.json`.
        See <https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/settings.md> for supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Assumed to exist by pi. See: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/src/utils/tools-manager.ts
    home.packages = [
      pkgs.fd
      pkgs.ripgrep
    ]
    ++ lib.optional (cfg.package != null) cfg.package;

    home.sessionVariables = lib.mkIf cfg.offline { PI_OFFLINE = "1"; };

    home.file.".pi/agent/settings.json" = lib.mkIf (cfg.settings != { }) {
      source = jsonFormat.generate "pi-settings" (
        cfg.settings // (lib.optionalAttrs (cfg.npmCommand != null) { inherit (cfg) npmCommand; })
      );
    };
  };
}
