{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.just ];
  };
}
