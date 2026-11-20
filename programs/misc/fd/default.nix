{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.fd ];
  };
}
