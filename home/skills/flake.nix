{
  description = "Skills downloader";

  inputs = {
    anthropic = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    { anthropic, ... }:
    {
      anthropic = builtins.readDir (anthropic + "/skills");
    };
}
