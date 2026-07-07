# User "zine" Home Manager entry point.
# Shared home configuration is imported from ../../modules/home.
{ ... }:

{
  imports = [
    ../../modules/home
  ];

  home.username = "zine";
  home.homeDirectory = "/home/zine";
}
