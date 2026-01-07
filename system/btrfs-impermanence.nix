{
  config,
  lib,
  inputs,
  ...
}:

(lib.mkIf config.misha.system.btrfsImpermanence.enable {
  assertions = [
    {
      assertion = !builtins.isNull config.misha.system.btrfsImpermanence.mainUser.hashedPasswordFile;
      message = "password for main user must exist";
    }
  ];

  # Automatically deletes root snapshosts older than 30 days
  boot.initrd.postResumeCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount -t btrfs /dev/mapper/enc /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  # stuff to keep
  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true; # sets x-gvfs-hide
    directories = [
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/var/lib/systemd/backlight"
      "/etc/NetworkManager/system-connections"
      "/var/lib/containers"
      "/var/lib/cni"
      "/var/lib/flatpak"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
})
