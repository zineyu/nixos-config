{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.gnumake ];
  };
}
