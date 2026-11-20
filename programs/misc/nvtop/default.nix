{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.nvtopPackages.full ];
  };
}
