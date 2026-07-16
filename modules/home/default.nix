{ ... }:

{
  imports = [
    ./common.nix
    ./tools.nix
    ./shell
    ./desktop
    ./programs
  ];

  home.username = "zine";
  home.homeDirectory = "/home/zine";
}
