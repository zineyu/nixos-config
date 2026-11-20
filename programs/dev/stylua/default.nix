{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.stylua ];
  };
}
