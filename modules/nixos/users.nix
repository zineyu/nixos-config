{
  pkgs,
  vars,
  ...
}:

{
  users.users."${vars.linux.user.name}" = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "render"
      "docker"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
  };
}
