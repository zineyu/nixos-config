{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.fzf ];
  };
}
