{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.jq ];
  };
}
