{
  pkgs,
  ...
}:

{
  config = {
    home.packages = [ pkgs.llvm ];
  };
}
