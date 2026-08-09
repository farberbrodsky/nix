{
  config,
  my-utils,
  lib,
  ...
}:

{
  programs.zathura = lib.mkIf config.misha.desktop.enable {
    enable = true;
    mappings = {
      "<A-z>" = "toggle_statusbar";
    };
    options = {
      selection-clipboard = "clipboard";
    };
  };
  xdg.mimeApps.defaultApplications = lib.mkIf config.misha.desktop.enable (
    my-utils.repeatedAttribute [ "application/pdf" "application/postscript" ] "org.pwmt.zathura.desktop"
  );
}
