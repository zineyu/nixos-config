{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.maven ];
  };
}
