{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.cmake ];
  };
}
