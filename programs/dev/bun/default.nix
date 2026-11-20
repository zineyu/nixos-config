{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.bun ];
  };
}
