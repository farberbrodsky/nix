{ pkgs, config, lib, ... }:

(lib.mkIf config.misha.system.btrfsImpermanence.enable {
  assertions = [
    {
      assertion = !builtins.isNull config.misha.system.btrfsImpermanence.mainUser.hashedPasswordFile;
      message = "password for main user must exist";
    }
  ];

  boot.initrd.systemd = {
    services.impermance-btrfs-rolling-root = {
      description = "Archiving existing BTRFS root subvolume and creating a fresh one";
      # Specify dependencies explicitly
      unitConfig.DefaultDependencies = false;
      # The script needs to run to completion before this service is done
      serviceConfig = {
        Type = "oneshot";
        # NOTE: to be able to see errors in your script do this
        # StandardOutput = "journal+console";
        # StandardError = "journal+console";
      };
      # This service is required for boot to succeed
      requiredBy = ["initrd.target"];
      # Should complete before any file systems are mounted
      before = ["sysroot.mount"];

      # Wait until the root device is available
      # If you're altering a different device, specify its device unit explicitly.
      # see: systemd-escape(1)
      requires = ["initrd-root-device.target"];
      after = [
        "initrd-root-device.target"
        # Allow hibernation to resume before trying to alter any data
        "local-fs-pre.target"
      ];

      # The body of the script. Make your changes to data here
      script = ''
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
    };
    extraBin = {
      # "mkfs.ext4" = "${pkgs.e2fsprogs}/bin/mkfs.ext4";
      "mkdir" = "${pkgs.coreutils}/bin/mkdir";
      "date" = "${pkgs.coreutils}/bin/date";
      "stat" = "${pkgs.coreutils}/bin/stat";
      "mv" = "${pkgs.coreutils}/bin/mv";
      "find" = "${pkgs.findutils}/bin/find";
      "btrfs" = "${pkgs.btrfs-progs}/bin/btrfs";
      # mount & umount already exist
    }; # NOTE: path = [...]; doesnt work for initrd, use full paths in your script or extraBin
  };

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
      "/var/lib/systemd/rfkill"
      "/etc/NetworkManager/system-connections"
      "/var/lib/containers"
      "/var/lib/cni"
      "/var/lib/flatpak"
      "/var/cache/tuigreet"
    ];
    files = [ "/etc/machine-id" ];
  };
})
