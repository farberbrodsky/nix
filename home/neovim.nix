{ config, pkgs, lib, ... }:

{
  # nix language server
  home.packages = [ pkgs.nil ];

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
	    "command" = "nil";
	    "filetypes" = [ "nix" ];
	    "rootPatterns" = [ "flake.nix" ];
	  };
	};
      };
    };

    plugins =
      with pkgs.vimExtraPlugins;
      let nvim-treesitter-textobjects = pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-treesitter-textobjects";
        version = "misha-main";
        src = pkgs.fetchurl {
          url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects/archive/0d7c800fadcfe2d33089f5726cb8907fc846eece.tar.gz";
          sha256 = "80b64ce89d9deb30f416c2a4e20ab98ce2d6328d1aef6a7205d8a3788c745412";
        };
      };
      in
      [
        catppuccin
        vim-airline
        nvim-surround
        indent-blankline-nvim
        vim-fugitive
        gitsigns-nvim
        hop-nvim
        telescope-nvim
        plenary-nvim
        nvim-treesitter
        # nvim-treesitter-textobjects
        { plugin = nvim-treesitter-textobjects; optional = true; }
        rainbow-delimiters-nvim
      ];
  };
}
