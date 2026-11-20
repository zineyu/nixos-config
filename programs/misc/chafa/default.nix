{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.chafa ];
  };
}
