let
  shared = import ../../../lib/nix-settings.nix;
in
{
  nix.settings = shared // {
    trusted-users = [ "zine" ];
  };

  nixpkgs.config.allowUnfree = true;
}
