{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.python3 ];
  };
}
