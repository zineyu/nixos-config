{
  pkgs,
  ...
}:

{
  config = {
    home.packages = with pkgs; [
      age
      sops
    ];
  };
}
