{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.zip ];
  };
}
