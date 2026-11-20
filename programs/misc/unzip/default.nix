{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.unzip ];
  };
}
