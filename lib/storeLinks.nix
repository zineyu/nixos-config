# Helpers for explicit in-store vs out-of-store symlinks.
#
# Use these in program modules so the choice of linking strategy is visible
# at the seam, not hidden in a bare `source = df "..."` call.
{ config }:

{
  # Link into the Nix store (default Home Manager behaviour for `source`).
  mkInStore = path: path;

  # Link directly to an absolute path outside the Nix store.
  # Required when the target is managed by the host system and must not be
  # copied into /nix/store (e.g. system-wide fontconfig files).
  mkOutOfStore = target: config.lib.file.mkOutOfStoreSymlink target;
}
