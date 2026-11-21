{ ... }:
{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.users.zine.extraGroups = [ "docker" ];
}
