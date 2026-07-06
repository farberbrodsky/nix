{ pkgs, lib, ... }:

let
  keys = {
    sway = {
      "volume up" = "mod+m";
    };
  };
in
{
  options.misha.keys = lib.mkOption { };
  config.home.file.".config/mishakeys.json".source =
    (pkgs.formats.json { }).generate "mishakeys.json"
      keys;
  config.home.packages = [
    (
      pkgs.python3Packages.buildPythonApplication {
        pname = "mishakeys";
        version = "1.0";
        buildInputs = [ pkgs.wofi ];
        src = ./keyboard-shortcuts;
        build-system = with pkgs.python3.pkgs; [ setuptools ];
        pyproject = true;
      }
    )
  ];
}
