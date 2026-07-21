{
  pkgs,
  ...
}:

{
  users.users.zine = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "render"
      "docker"
    ];
    shell = pkgs.fish;
  };
}
