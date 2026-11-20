{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.gcc ];
  };
}
