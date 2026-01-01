{ config, pkgs, lib, ... }:

{
  services.blueman-applet.enable = true;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gruvbox-gtk-theme;
      name = "gruvbox-gtk-theme";
    };
    iconTheme = {
      package = pkgs.gruvbox-plus-icons;
      name = "gruvbox-plus-icons";
    };
    font.package = pkgs.google-fonts;
    font.name = "Roboto";
  };

  # thank you so much github.com/spikespaz/dotfiles
  home.pointerCursor = {
    package = pkgs.quintom-cursor-theme;
    name = "Quintom_Ink";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
  home.sessionVariables.XCURSOR_SIZE = toString 24;

  home.file.".config/qt5ct/style-colors.conf".source = dotfiles/gruvbox_light.conf;
  home.file.".config/qt6ct/style-colors.conf".source = dotfiles/gruvbox_light.conf;
  qt = rec {
    enable = true;
    platformTheme.name = "qtct";
    qt5ctSettings = {
      Appearance = {
        color_scheme_path = builtins.toString dotfiles/gruvbox_light.conf;
        custom_palette = "true";
        style = "kvantum";
        icon_theme = config.gtk.iconTheme.name;
        standar_dialogs = "xdgdesktopportal";
      };
      Fonts = {
        fixed = "\"ComicShannsMono Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular\"";
        general = "\"Roboto,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,Regular\"";
      };
    };
    qt6ctSettings = qt5ctSettings;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    config = {
      sway = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  # from xdg-desktop-portal's manpage
  xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
    [screencast]
    max_fps=30
    chooser_type=simple
    chooser_cmd=slurp -f %o -or
  '';

  home.packages = with pkgs; [
    kdePackages.dolphin
    apostrophe
    slurp  # select a region in wayland
    brightnessctl
    pavucontrol
    libnotify  # notify-send, probably used by way-displays
    # theme
    (gruvbox-kvantum.override { variant = "Gruvbox_Light_Blue"; })
    # gruvbox-plus-icons doesn't work for light theme; TODO open a pr about it
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum

    # random desktop apps
    keepassxc
    inkscape
  ];

  services.flatpak.enable = true;

  misha.desktop.keyboardShortcuts = {
    "Mod4+z" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
    "Mod4+b" = "${pkgs.firefox}/bin/firefox";
  };
}
