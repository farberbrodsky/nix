{ pkgs, lib, ... }:

{
  # rebuild KDE's app cache in every activation because dolphin (and other kde apps) uses THIS for some reason
  home.activation.rebuildKDECache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -rf ~/.cache/ksycoca*
    ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental >/dev/null 2>&1 || echo "kbuildsyoca6 FAILED"
  '';
  xdg.configFile."menus/applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN" "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
    <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <Include>
        <All/>
      </Include>
    </Menu>
  '';
}
