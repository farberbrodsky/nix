_:

let
  identity = import ./identity.nix;
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = identity.fullName;
      user.email = identity.email;
      diff.tool = "nvimdiff";
      init.defaultBranch = "main";
    };
  };
}
