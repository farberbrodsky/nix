{
  config,
  lib,
  pkgs,
  ...
}:
(lib.mkMerge [
  (lib.mkIf config.misha.desktop.gaming.minecraft.enable { home.packages = with pkgs; [ prismlauncher ]; })
])
