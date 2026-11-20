{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.buf ];
  };
}
