{
  config,
  lib,
  pkgs,
  ...
}:

(lib.mkIf config.misha.desktop.enable {
  home.packages = [ pkgs.kitty ];
  home.file.".config/kitty/kitty.conf".source = pkgs.replaceVars ./dotfiles/kitty.conf {
    open_filemanager = "${pkgs.writeShellApplication {
      name = "open_filemanager_kitten";
      runtimeInputs = [ pkgs.jq pkgs.kdePackages.dolphin ];
      text = ''
        active_cwd="$(kitten @ ls | jq -r "map(select(.is_focused == true)) | .[0].tabs | map(select(.is_focused == true)) | .[0].windows | map(select(.is_focused == true)) | .[0].cwd")";
        exec dolphin --new-window -- "$active_cwd"
      '';
    }}/bin/open_filemanager_kitten";
  };
})
