{ pkgs, config, ... }:

{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "pi-coding-agent";
      buildInputs = [ pkgs.makeWrapper ];
      paths = [ pkgs.pi-coding-agent ];
      postBuild = ''
        wrapProgram $out/bin/pi \
          --set PI_SKIP_VERSION_CHECK 1 \
          --set NPM_CONFIG_PREFIX ${config.home.homeDirectory}/.pi/npm/ \
          --prefix PATH : ${
            pkgs.lib.makeBinPath [
              pkgs.nodejs_latest
              pkgs.fd
              pkgs.ripgrep
            ]
          }
      '';
    })
  ];
}
