{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.lnav ];
  };
}
