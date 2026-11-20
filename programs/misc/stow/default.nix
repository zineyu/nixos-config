{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.stow ];
  };
}
