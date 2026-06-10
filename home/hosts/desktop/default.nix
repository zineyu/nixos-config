# Host-specific overrides for the `desktop` machine.
#
# IMPORTANT: This is NOT the place for general "desktop" role configuration.
# Shared desktop settings (compositor, bar, wayland tools, etc.) belong in
# `home/common/desktop.nix`. This module is only for overrides that apply to
# THIS SPECIFIC machine, e.g. display scaling, external monitor layout,
# hardware-specific packages, or per-machine program toggles.
#
# If this host shares its full configuration with the generic desktop role,
# leaving this file empty (or comment-only) is correct.
{ ... }:

{
  # Add host-specific settings here when needed.
}
