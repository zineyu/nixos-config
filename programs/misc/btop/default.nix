{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.btop ];
  };
}
