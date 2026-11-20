{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.go ];
  };
}
