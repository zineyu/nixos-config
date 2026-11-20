{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.uv ];
  };
}
