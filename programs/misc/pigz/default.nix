{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.pigz ];
  };
}
