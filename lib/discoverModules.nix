# Discover submodules under a directory.
#
# Given a base directory, return the list of immediate subdirectories that contain
# a default.nix file. This keeps orchestrator modules (programs, desktop, shell)
# from maintaining a hand-written import list.
#
# Usage:
#   imports = import ../../../lib/discoverModules.nix { baseDir = ./.; inherit lib; };
{ baseDir, lib }:

let
  entries = builtins.readDir baseDir;

  isModuleDir =
    name: type: type == "directory" && builtins.pathExists (baseDir + "/${name}/default.nix");

  moduleNames = builtins.attrNames (lib.filterAttrs isModuleDir entries);
in

map (name: baseDir + "/${name}") (builtins.sort builtins.lessThan moduleNames)
