{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.websocat ];
  };
}
