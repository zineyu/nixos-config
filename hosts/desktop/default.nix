# Host definition for the `desktop` machine.
#
# This repository currently builds a standalone Home Manager configuration, so
# host-specific differences are represented as additional Home Manager modules.
{
  username = "zine";
  system = "x86_64-linux";

  modules = [
    ({ ... }: {
      # Add settings that apply only to this physical machine here, e.g.
      # monitor layout, hardware-specific packages, or per-machine toggles.
    })
  ];
}
