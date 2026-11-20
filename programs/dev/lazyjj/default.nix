{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.lazyjj ];
  };
}
