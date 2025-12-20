{ config, pkgs, lib, ... }:

{
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
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    # qt5ctSettings = {
    #   Appearance = {
    #     style = "kvantum";
    #     icon_theme = config.gtk.iconTheme.name;
    #     standar_dialogs = "xdgdesktopportal";
    #   };
    #   Fonts = {
    #     fixed = "\"ComicShannsMono Nerd Font,12,-1,5,50,0,0,0,0,0\"";
    #     general = "\"Calibri,12,-1,5,50,0,0,0,0,0\"";
    #   };
    # };
    # qt6ctSettings = qt5ctSettings;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
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
    keepassxc
    apostrophe
    slurp  # select a region in wayland
    brightnessctl
    libnotify  # notify-send, probably used by way-displays
    # theme
    (gruvbox-kvantum.override { variant = "Gruvbox_Light_Blue"; })
    gruvbox-plus-icons
    libsForQt5.qtstyleplugin-kvantum
    qt6Packages.qtstyleplugin-kvantum
    papirus-icon-theme
  ];

  misha.desktop.keyboardShortcuts = {
    "Mod4+z" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
    "Mod4+b" = "${pkgs.firefox}/bin/firefox";
  };
}
