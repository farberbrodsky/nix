{ pkgs, config, ... }:

{
  programs.pi-coding-agent = {
    enable = true;
    settings = {
      theme = "light";
      defaultProvider = "google-antigravity";
      defaultModel = "gemini-3-flash";
      defaultThinkingLevel = "medium";
      packages = ["npm:pi-subagents" "npm:pi-mcp-adapter"];
    };
  };
}
