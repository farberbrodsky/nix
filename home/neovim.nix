{
  config,
  pkgs,
  lib,
  ...
}:

{
  # nix language server
  home.packages = [ pkgs.nixd ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraLuaConfig = lib.fileContents neovim/init.lua;

    coc = {
      enable = true;
      settings = {
        "coc.preferences.formatOnSaveFiletypes" = [ "rust" ];
        "coc.preferences.hoverTarget" = "preview";
        "eslint.autoFixOnSave" = true;
        "languageserver" = {
          "nix" = {
            "command" = "nixd";
            "filetypes" = [ "nix" ];
            "rootPatterns" = [ "flake.nix" ];
          };
        };
      };
    };

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
        pkgs.vimExtraPlugins.catppuccin
        pkgs.vimExtraPlugins.vim-airline
        pkgs.vimExtraPlugins.nvim-surround
        pkgs.vimExtraPlugins.indent-blankline-nvim
        pkgs.vimExtraPlugins.vim-fugitive
        pkgs.vimExtraPlugins.gitsigns-nvim
        pkgs.vimExtraPlugins.hop-nvim
        pkgs.vimExtraPlugins.telescope-nvim
        pkgs.vimExtraPlugins.plenary-nvim
        pkgs.vimExtraPlugins.nvim-treesitter
        pkgs.vimExtraPlugins.nvim-autopairs
        {
          plugin = nvim-treesitter-textobjects;
          optional = true;
        }
        rainbow-delimiters-nvim
        nerdtree
        vim-devicons
        vim-lion
        tcomment_vim
        telescope-coc-nvim
        vim-obsession
        nvim-autopairs
        vim-nix
      ];
  };
}
