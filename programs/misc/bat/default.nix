{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.bat ];
  };
}
