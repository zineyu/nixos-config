{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.ninja ];
  };
}
