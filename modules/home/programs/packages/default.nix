{ pkgs, ... }:

{
  # Programs enabled with their default Home Manager module and no extra
  # configuration. Declared here so each program does not need its own
  # one-line module directory.
  programs.chromium.enable = true;
  programs.dbeaver.enable = true;
  programs.firefox.enable = true;
  programs.thunderbird.enable = true;

  home.packages = with pkgs; [
    localsend
    python3
    python3Packages.pip
    qq
  ];
}
