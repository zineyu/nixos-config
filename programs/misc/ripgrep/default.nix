{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.ripgrep ];
  };
}
