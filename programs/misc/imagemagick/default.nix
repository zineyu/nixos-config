{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.imagemagick ];
  };
}
