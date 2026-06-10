# Host definitions for multi-system Home Manager configurations.
#
# To add a new host:
#   1. Append an entry here with `username` and `system`.
#   2. Create `hosts/<hostname>.nix` for host-specific modules/overrides.
#   3. Run `home-manager switch --flake .#<username>@<hostname>`.
{
  desktop = {
    username = "zine";
    system = "x86_64-linux";
  };
}
