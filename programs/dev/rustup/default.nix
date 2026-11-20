{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.rustup ];
  };
}
