{ pkgs, ... }:

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
in
{
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
      modern-python.source = trailofbits-skills + "/plugins/modern-python/skills/modern-python";
    };
  };
  home.file.".pi/agent/mcp.json".source = jsonFormat.generate "pi-mcp" {
    mcpServers = {
      chrome-devtools = {
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--no-usage-statistics"
          "--executable-path"
          "${pkgs.chromium}/bin/chromium"
        ];
      };
    };
  };
}
