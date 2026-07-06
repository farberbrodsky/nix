{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.misha.keys = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
    default = { };
    description = "Keyboard shortcuts organized by category. Each entry maps a description string to a keybinding string.";
  };
  config.home.file.".config/mishakeys.json".source =
    (pkgs.formats.json { }).generate "mishakeys.json"
      config.misha.keys;
  config.home.packages = [
    (pkgs.python3Packages.buildPythonApplication {
      pname = "mishakeys";
      version = "1.0";
      buildInputs = [
        pkgs.wofi
        pkgs.wl-clipboard
      ];
      src = ./keyboard-shortcuts;
      build-system = with pkgs.python3.pkgs; [ setuptools ];
      pyproject = true;
    })
  ];
}
