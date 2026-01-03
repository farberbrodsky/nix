{
  pkgs,
  ...
}:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.comic-shanns-mono
    corefonts # microsoft
    vista-fonts # microsoft
    google-fonts
  ];
}
