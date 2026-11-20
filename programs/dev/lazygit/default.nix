{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.lazygit ];
  };
}
