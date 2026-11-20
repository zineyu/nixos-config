{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.resvg ];
  };
}
