{
  config,
  lib,
  ...
}:

{
  programs.obsidian = lib.mkIf config.misha.desktop.enable {
    enable = true;
  };
}
