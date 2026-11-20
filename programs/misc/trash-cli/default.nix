{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.trash-cli ];
  };
}
