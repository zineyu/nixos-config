{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.eza ];
  };
}
