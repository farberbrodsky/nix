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

    skipVersionCheck = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Skips the version check on startup.
        Otherwise, "Update Available" is always shown.
        Corresponds to {env}`PI_SKIP_VERSION_CHECK`.
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

    skills = lib.mkOption {
      type = lib.types.either (lib.types.attrsOf (lib.types.either lib.types.lines lib.types.path)) lib.types.path;
      default = { };
      example = lib.literalExpression ''
        {
          xlsx = ./skills/xlsx/SKILL.md;
          data-analysis = ./skills/data-analysis;
          pdf-processing = '''
            ---
            name: pdf-processing
            description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
            ---

            # PDF Processing

            ## Quick start

            Use pdfplumber to extract text from PDFs:

            ```python
            import pdfplumber

            with pdfplumber.open("document.pdf") as pdf:
                text = pdf.pages[0].extract_text()
            ```
          ''';
        }
      '';
      description = ''
        Custom skills for pi-coding-agent.

        This option can be either:
        - An attribute set defining skills
        - A path to a directory containing skill folders

        If an attribute set is used, the attribute name becomes the
        skill directory name, and the value is either:
        - Inline content as a string (creates `~/.pi/agent/skills/<name>/SKILL.md`)
        - A path to a file (creates `~/.pi/agent/skills/<name>/SKILL.md`)
        - A path to a directory (symlinks `~/.pi/agent/skills/<name>/` to that directory)

        If a path is used, it is expected to contain one folder per
        skill name, each containing a {file}`SKILL.md`. The directory is
        symlinked to {file}`~/.pi/agent/skills/`.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.pi-coding-agent.settings.npmCommand = lib.mkIf (cfg.npmCommand != null) cfg.npmCommand;
      }
      {
        # fd and ripgrep assumed to exist by pi. See: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/src/utils/tools-manager.ts
        home = {
          packages = [
            pkgs.fd
            pkgs.ripgrep
          ]
          ++ lib.optional (cfg.package != null) cfg.package;
          file.".pi/agent/settings.json" = lib.mkIf (cfg.settings != { }) {
            source = jsonFormat.generate "pi-settings" cfg.settings;
          };
        };
      }
      (lib.mkIf cfg.offline {
        home.sessionVariables.PI_OFFLINE = "1";
      })
      (lib.mkIf cfg.skipVersionCheck {
        home.sessionVariables.PI_SKIP_VERSION_CHECK = "1";
      })
      {
        assertions = [
          {
            assertion = !lib.isPath cfg.skills || lib.pathIsDirectory cfg.skills;
            message = "`programs.pi-coding-agent.skills` must be a directory when set to a path";
          }
        ];
      }
      (lib.mkIf (cfg.skills != { }) {
        home.file =
          if lib.isPath cfg.skills then
            {
              ".pi/agent/skills" = {
                source = cfg.skills;
                recursive = true;
              };
            }
          else
            lib.mapAttrs' (
              n: v:
              if lib.isPath v && lib.pathIsDirectory v then
                lib.nameValuePair ".pi/agent/skills/${n}" {
                  source = v;
                  recursive = true;
                }
              else
                lib.nameValuePair ".pi/agent/skills/${n}/SKILL.md" (
                  if lib.isPath v then { source = v; } else { text = v; }
                )
            ) cfg.skills;
      })
    ]
  );
}
