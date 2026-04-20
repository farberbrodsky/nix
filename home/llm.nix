{ inputs, pkgs, ... }:

let
  jsonFormat = pkgs.formats.json { };
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
    skills = inputs.skills.anthropic;
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
