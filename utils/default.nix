{ nixpkgs, ... }:

let
  lib = nixpkgs.lib;
in
{
  mkDefaultEnableOption =
    default: name:
    lib.mkOption {
      inherit default;
      example = true;
      description = "Whether to enable ${name}.";
      type = lib.types.bool;
    };

  repeatedAttribute =
    names: value: builtins.listToAttrs (builtins.map (name: { inherit name value; }) names);
}
