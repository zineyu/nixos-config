{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.dart-sass ];
  };
}
