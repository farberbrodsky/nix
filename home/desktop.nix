{
  config,
  my-utils,
  pkgs,
  lib,
  ...
}:

(lib.mkIf config.misha.desktop.enable {
  services.blueman-applet.enable = true;

  gtk = {
    enable = true;
    theme = {
      package = pkgs.gruvbox-gtk-theme;
      name = "gruvbox-gtk-theme";
    };
    iconTheme = {
      package = pkgs.gruvbox-plus-icons;
      name = "Gruvbox-Plus-Light";
    };
    gtk4.theme = config.gtk.theme;
    gtk4.iconTheme = config.gtk.theme;
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

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = my-utils.repeatedAttribute [
    "text/html"
    "application/x-web-browser"
    "text/html"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ] config.misha.desktop.default.browser;

  xdg.mimeApps.defaultApplicationPackages = with pkgs; [
    kdePackages.ark
    feh
    vlc
  ];

  # KDE globals
  xdg.configFile."kdeglobals".text = ''
    [General]
    TerminalApplication=kitty
  '';

  # Dolphin keyboard shortcuts: version="0" loses the version race against
  # Dolphin's built-in dolphinui.rc, so these ActionProperties are merged on
  # top of the current defaults (no full UI snapshot needed).
  xdg.dataFile."kxmlgui5/dolphin/dolphinui.rc".text = ''
    <?xml version='1.0'?>
    <!DOCTYPE gui SYSTEM 'kpartgui.dtd'>
    <gui name="dolphin" version="0">
      <ActionProperties scheme="Default">
        <Action name="open_terminal_here" shortcut="Ctrl+Return"/>
      </ActionProperties>
    </gui>
  '';

  home.packages =
    with pkgs;
    [
      kdePackages.dolphin
      kdePackages.ark
      apostrophe
      slurp # select a region in wayland
      brightnessctl
      pavucontrol
      libnotify # notify-send, probably used by way-displays
      vlc
      feh
      # theme
      (gruvbox-kvantum.override { variant = "Gruvbox_Light_Blue"; })
      gruvbox-plus-icons
      libsForQt5.qtstyleplugin-kvantum
      qt6Packages.qtstyleplugin-kvantum
    ]
    ++ lib.lists.optional config.misha.desktopApps.keepassxc.enable pkgs.keepassxc
    ++ lib.lists.optional config.misha.desktopApps.inkscape.enable pkgs.inkscape;

  services.flatpak.enable = true;

  misha.desktop.keyboardShortcuts = {
    "Mod4+z" = "${pkgs.kdePackages.dolphin}/bin/dolphin";
    "Mod4+b" = "${pkgs.firefox}/bin/firefox";
  };
})
