{
  config,
  lib,
  pkgs,
  ...
}:

let
  jsonFormat = pkgs.formats.json { };
  anthropic-skills = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "2c7ec5e78b8e5d43ea02e90bb8826f6b9f147b0c";
    hash = "sha256-BMgH43diojdUrGC6ivk87eEm2W1yWNuh2fpR9JpbUnE=";
  };
  trailofbits-skills = pkgs.fetchFromGitHub {
    owner = "trailofbits";
    repo = "skills";
    rev = "e8cc5baf9329ccb491bfa200e82eacbac83b1ead";
    hash = "sha256-ahuJDSIpUW2Zl5SbhyWXwMLFCYIjPygQPSfFeISXdHc=";
  };
  oh-pi = pkgs.fetchFromGitHub {
    owner = "ifiokjr";
    repo = "oh-pi";
    rev = "e431647671f88534e6d23576d4e495cf99eda06a";
    hash = "sha256-ydTCWMins5mC7n7/MdpVz3N5Kt+x2FFtkOQgWLNlltk=";
  };
in
lib.mkIf config.misha.shell.llms.enable {
  home.packages = with pkgs; [ extra-node.pi-acp ];
  programs.pi-coding-agent = {
    enable = true;
    settings = {
      theme = "light";
      defaultProvider = "google-antigravity";
      defaultModel = "gemini-3-flash";
      defaultThinkingLevel = "medium";
      packages = [
        "npm:pi-subagents"
        "npm:pi-mcp-adapter"
      ];
    };
    skills = {
      skill-creator.source = anthropic-skills + "/skills/skill-creator";
      pdf.source = anthropic-skills + "/skills/pdf";
      modern-python.source = trailofbits-skills + "/plugins/modern-python/skills/modern-python";
      skill-extractor.source = builtins.toString ./skills/skill-extractor;
      web-search.source = oh-pi + "/packages/skills/skills/web-search";
    };
    promptTemplates = {
      commit = builtins.readFile (oh-pi + "/packages/prompts/prompts/commit.md");
    };
  };
  home.file.".pi/agent/mcp.json".source = jsonFormat.generate "pi-mcp" {
    mcpServers = {
      chrome-devtools = {
        command = "${pkgs.extra-node.chrome-devtools-mcp}/bin/chrome-devtools-mcp";
        args = [
          "--no-usage-statistics"
          "--executable-path"
          "${pkgs.chromium}/bin/chromium"
        ];
      };
      nixos = {
        command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
      };
    };
  };
}
