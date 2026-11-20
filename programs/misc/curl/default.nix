{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.curl ];
  };
}
