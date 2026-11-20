{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.pandoc ];
  };
}
