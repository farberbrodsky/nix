{ buildNpmPackage, fetchFromGitHub, ... }: {
  pi-acp = buildNpmPackage {
    pname = "pi-acp";
    version = "0.0.27";
    src = fetchFromGitHub {
      owner = "svkozak";
      repo = "pi-acp";
      rev = "138edb025c94bd6a61fbcfe2be8b392cceab6982";
      hash = "sha256-Bb7qQkELDY175ZNmJD70LzmkcmoQL1LWAnfIxN+ttso=";
    };
    npmDepsHash = "sha256-EmzhcvVzrirlKh57Tl4BKVG4XLkAgdaYgdhMfpZVbRI=";
  };
  # chrome-devtools-mcp = buildNpmPackage {
  #   pname = "chrome-devtools-mcp";
  #   version = "1.1.1";
  #   src = fetchFromGitHub {
  #     owner = "ChromeDevTools";
  #     repo = "chrome-devtools-mcp";
  #     rev = "3ba70d350a135f5b444826f204724d08aaa9b924";
  #     hash = "sha256-H+vlHwvQylScZIoHcQDcrnREiUg7K4phzymzPLnubrk=";
  #   };
  #   npmDepsHash = "sha256-7iJP3RC8FYvDvr9W95nVTBqMxLZd8EBiCTNGgCBQQhQ=";
  #
  #   dontNpmBuild = true;
  #
  #   # for some reason, typescript typechecking failed for me
  #   # postPatch = ''
  #   #   substituteInPlace package.json --replace "tsc && " "tsc --noCheck && "
  #   # '';
  #
  #   env = {
  #     PUPPETEER_SKIP_DOWNLOAD = "1";
  #   };
  # };
}
