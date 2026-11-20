{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.ncdu ];
  };
}
