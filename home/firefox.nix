{
  pkgs,
  config,
  lib,
  ...
}:

{
  # adapted from https://github.com/drupol/infra. thank you!
  programs.firefox = lib.mkIf config.misha.desktop.enable {
    enable = true;
    nativeMessagingHosts =
      with pkgs;
      lib.lists.optional config.misha.desktopApps.keepassxc.enable keepassxc;
    profiles.default = {
      id = 0;
      isDefault = true;
      name = "Default";
      # rycee is a maintainer of home-manager i think
      extensions.packages =
        with pkgs.nur.repos.rycee.firefox-addons;
        [ ublock-origin ] ++ lib.lists.optional config.misha.desktopApps.keepassxc.enable keepassxc-browser;
      search = {
        default = "ddg";
        force = true;
        engines = {
          "archwiki" = {
            urls = [
              {
                template = "https://wiki.archlinux.org/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                  {
                    name = "title";
                    value = "Special:Search";
                  }
                  {
                    name = "wprov";
                    value = "acrw1_-1";
                  }
                ];
              }
            ];

            icon = "https://wiki.archlinux.org/favicon.ico";
            updateInterval = 24 * 60 * 60 * 1000; # every day

            definedAliases = [ "@aw" ];
          };

          "nix-packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "nixos-wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                  {
                    name = "title";
                    value = "Special:Search";
                  }
                  {
                    name = "wprov";
                    value = "acrw1_-1";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };

          "noogle-dev-search" = {
            urls = [ { template = "https://noogle.dev/q?q={searchTerms}"; } ];
            icon = "https://noogle.dev/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [
              "@ng"
              "@nog"
            ];
          };

          "bing".metaData.hidden = true;
          "amazonnl".metaData.hidden = true;
          "ebay".metaData.hidden = true;
          "google".metaData.alias = "@g";
        };
      };
      settings = {
        "browser.aboutwelcome.enabled" = false;
        "app.update.auto" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.urlbar.update2.engineAliasRefresh" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "";
        "cookiebanners.service.mode" = 2;
        # Enable HTTPS-Only Mode
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        # Privacy settings
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.partition.network_state.ocsp_cache" = true;
        # Disable all sorts of telemetry
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.fullscreen.autohide" = false;
        "browser.newtabpage.activity-stream.topSitesRows" = 0;
        "browser.urlbar.quickactions.enabled" = true;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.search.hiddenOneOffs" = "Google,Yahoo,Bing,Amazon.com,Twitter";
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "browser.urlbar.trimURLs" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.searches" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        # As well as Firefox 'experiments'
        "experiments.activeExperiment" = false;
        "experiments.enabled" = false;
        "experiments.supported" = false;
        "network.allow-experiments" = false;
        # Disable Pocket Integration
        "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
        "extensions.pocket.enabled" = false;
        "extensions.pocket.api" = "";
        "extensions.pocket.oAuthConsumerKey" = "";
        "extensions.pocket.showHome" = false;
        "extensions.pocket.site" = "";
        # Allow copy to clipboard
        "dom.events.asyncClipboard.clipboardItem" = true;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.location" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;
        "widget.use-xdg-desktop-portal.open-uri" = 1;
        "widget.use-xdg-desktop-portal.settings" = 1;

        "privacy.donottrackheader.value" = 1;
        "findbar.modalHighlight" = true;
        "datareporting.healthreport.uploadEnabled" = false;

        # override fonts
        # "font.minimum-size.x-western" = 12;
        # "font.size.fixed.x-western" = 14;
        # "font.size.monospace.x-western" = 14;
        # "font.size.variable.x-western" = 14;
        # "font.name.monospace.x-western" = "${defaultFont}";
        # "font.name.sans-serif.x-western" = "${defaultFont}";
        # "font.name.serif.x-western" = "${defaultFont}";
        # "browser.display.use_document_fonts" = 0;

        # Disable mailto popup
        # "network.protocol-handler.external.mailto" = false;

        # Don't use the built-in password manager.
        "signon.rememberSignons" = false;
      };
    };
  };
}
