{ ... }:

{
  imports = [
    ./common.nix
    ./tools.nix
    ./shell
    ./desktop
    ./programs
    ./ssh.nix
  ];

  home.username = "zine";
  home.homeDirectory = "/home/zine";
}
