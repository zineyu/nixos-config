# Registry of standalone Home Manager host configurations.
#
# To add a new host:
#   1. Create hosts/<hostname>/default.nix with username, system and modules.
#   2. Run `home-manager build --flake .#<username>@<hostname>`.
{
  desktop = import ./desktop;
}
