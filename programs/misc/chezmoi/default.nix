{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.chezmoi ];
  };
}
