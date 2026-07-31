{ inputs, pkgs, ... }:

{
  home.packages = [ inputs.dbx.packages.${pkgs.stdenv.hostPlatform.system}.dbx-desktop ];
}
