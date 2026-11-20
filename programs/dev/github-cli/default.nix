{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.github-cli ];
  };
}
