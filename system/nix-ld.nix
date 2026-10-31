{
  pkgs,
  config,
  lib,
  ...
}:

(lib.mkIf config.misha.system.nix-ld.enable {
  # list of packages taken from https://github.com/Mic92/dotfiles/blob/5c715335df1a137b474dd50df0e409c3e8aec71f/nixosModules/fhs-compat.nix
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries =
    with pkgs;
    [
      acl
      attr
      bzip2
      dbus
      expat
      fontconfig
      freetype
      fuse3
      icu
      libnotify
      libsodium
      libssh
      libunwind
      libusb1
      libuuid
      nspr
      nss
      stdenv.cc.cc
      util-linux
      zlib
      zstd
    ]
    ++ lib.optionals config.misha.desktop.enable [
      pipewire
      cups
      libxkbcommon
      pango
      mesa
      libdrm
      libglvnd
      libpulseaudio
      atk
      cairo
      alsa-lib
      at-spi2-atk
      at-spi2-core
      gdk-pixbuf
      glib
      gtk3
      libGL
      libappindicator-gtk3
      vulkan-loader
      libx11
      libxscrnsaver
      libxcomposite
      libxcursor
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libxrender
      libxtst
      libxcb
      libxkbfile
      libxshmfence
      wayland
    ];
})
