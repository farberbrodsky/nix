{
  pkgs,
  config,
  lib,
  ...
}:

(lib.mkIf config.misha.system.libvirt.enable {
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
  };
  misha.system.user.extraGroups = [ "libvirtd" ];
  programs.virt-manager = lib.mkIf config.misha.system.libvirt.virt-manager.enable { enable = true; };
})
