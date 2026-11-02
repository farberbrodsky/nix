{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Language servers and coc extensions, enabled through the matching
  # `misha.shell.lsp.<name>` options. Keys are the names used by coc's
  # `languageserver` setting where an explicit server config is needed.
  lsps =
    lib.optionalAttrs config.misha.shell.lsp.rust {
      rust = {
        packages = [ pkgs.rust-analyzer ];
        formatOnSave = true;
        coc = {
          command = "rust-analyzer";
          filetypes = [ "rust" ];
          rootPatterns = [ "Cargo.toml" ];
        };
      };
    }
    // lib.optionalAttrs config.misha.shell.lsp.java {
      java = {
        packages = [ pkgs.jdt-language-server ];
        coc = {
          command = "jdtls";
          filetypes = [ "java" ];
          rootPatterns = [ "build.gradle" ];
        };
      };
    }
    // lib.optionalAttrs config.misha.shell.lsp.nix {
      nix = {
        packages = [ pkgs.nixd ];
        coc = {
          command = "nixd";
          filetypes = [ "nix" ];
          rootPatterns = [ "flake.nix" ];
        };
      };
    }
    // lib.optionalAttrs config.misha.shell.lsp.clangd {
      clangd = {
        packages = [ pkgs.clang-tools ];
        vimPlugins = [ pkgs.vimPlugins.coc-clangd ];
      };
    }
    // lib.optionalAttrs config.misha.shell.lsp.shell {
      sh = {
        packages = [
          pkgs.shellcheck
          pkgs.shfmt
        ];
        vimPlugins = [ pkgs.vimPlugins.coc-sh ];
      };
    }
    // lib.optionalAttrs config.misha.shell.lsp.zig {
      zig = {
        # zls is versioned per project, so it is deliberately not installed
        # here; `command = "zls"` resolves whatever the project provides on PATH.
        coc = {
          command = "zls";
          filetypes = [ "zig" ];
          rootPatterns = [ "build.zig" ];
        };
      };
    }
    // lib.optionalAttrs config.misha.shell.lsp.python {
      python = {
        vimPlugins = [ pkgs.vimPlugins.coc-pyright ];
      };
    };

  enabledLsps = lib.attrValues lsps;

  # Vim plugins (coc extensions) that accompany a language server.
  vimPlugins = lib.concatMap (lsp: lsp.vimPlugins or [ ]) enabledLsps;
  cocLanguageServers = lib.listToAttrs (
    lib.concatMap (name: lib.optional (lsps.${name} ? coc) (lib.nameValuePair name lsps.${name}.coc)) (
      lib.attrNames lsps
    )
  );

  formatOnSaveFiletypes = lib.concatMap (
    lsp: if lsp.formatOnSave or false then lsp.coc.filetypes else [ ]
  ) enabledLsps;
in

{
  # language servers
  home.packages = [
    pkgs.rustc
    pkgs.cargo
    (pkgs.writeShellScriptBin "nv" ''
      if [ "$#" == "0" ]; then
        exec nvim --server /run/user/${toString config.misha.uid}/nvim-daemon --remote-ui
      else
        exec nvim --server /run/user/${toString config.misha.uid}/nvim-daemon --remote-tab "$@"
      fi
    '')
  ]
  ++ lib.concatMap (lsp: lsp.packages or [ ]) enabledLsps;

  # global neovim instance
  systemd.user.services.nvim-daemon = {
    Unit = {
      Description = "Misha's Neovim Daemon Service";
    };
    Service = {
      Type = "simple";
      ExecStart = "${config.programs.neovim.package}/bin/nvim --headless --listen %t/nvim-daemon";
      Restart = "always";
      RestartSec = "5";
      WorkingDirectory = "%h";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = true;

    initLua = lib.fileContents neovim/init.lua;

    coc = {
      enable = true;
      settings = {
        "coc.preferences.formatOnSaveFiletypes" = formatOnSaveFiletypes;
        "coc.preferences.hoverTarget" = "preview";
        "eslint.autoFixOnSave" = true;
        "languageserver" = cocLanguageServers;
      };
    };

    # You can search plugins with:
    # 1. `nix search nixpkgs "vimPlugins\..*pluginname"`, for pkgs.vimPlugins
    # 2. `nix search nixneovimplugins pluginname`, for pkgs.vimExtraPlugins (this is the prefix for results in nixneovimplugins)
    # Usually, prioritize the regular vimPlugins.
    plugins =
      with pkgs.vimPlugins;
      let
        nvim-treesitter-textobjects = pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-treesitter-textobjects";
          version = "misha-main";
          src = pkgs.fetchurl {
            url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/archive/0d7c800fadcfe2d33089f5726cb8907fc846eece.tar.gz";
            sha256 = "80b64ce89d9deb30f416c2a4e20ab98ce2d6328d1aef6a7205d8a3788c745412";
          };
        };
      in
      [
        pkgs.vimExtraPlugins.catppuccin-catppuccin
        pkgs.vimExtraPlugins.vim-airline-vim-airline
        pkgs.vimExtraPlugins.vim-airline-themes-vim-airline
        pkgs.vimExtraPlugins.nvim-surround-kylechui
        pkgs.vimExtraPlugins.indent-blankline-nvim-lukas-reineke
        pkgs.vimExtraPlugins.vim-fugitive-tpope
        pkgs.vimExtraPlugins.gitsigns-nvim-lewis6991
        pkgs.vimExtraPlugins.hop-nvim-smoka7
        pkgs.vimExtraPlugins.telescope-nvim-nvim-telescope
        pkgs.vimExtraPlugins.plenary-nvim-nvim-lua
        pkgs.vimExtraPlugins.nvim-treesitter-nvim-treesitter
        pkgs.vimExtraPlugins.nvim-autopairs-windwp
        {
          plugin = nvim-treesitter-textobjects;
          optional = true;
        }
        rainbow-delimiters-nvim
        nerdtree
        nvim-web-devicons
        vim-lion
        tcomment_vim
        telescope-coc-nvim
        vim-obsession
        nvim-autopairs
        vim-nix
        gruvbox-nvim
        {
          plugin = demicolon-nvim;
          optional = true;
        }
        diffview-nvim
      ]
      ++ vimPlugins;
  };
}
