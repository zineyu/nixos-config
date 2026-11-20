{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.bitwarden-cli ];
  };
}
