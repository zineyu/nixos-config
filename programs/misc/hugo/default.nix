{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.hugo ];
  };
}
