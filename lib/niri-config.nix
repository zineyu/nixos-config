# Generate the niri config string with Nix store paths substituted for
# every `include "dms/<file>.kdl"` found in the niri config directory.
#
# This module scans the dms/ directory automatically, so adding a new
# `include "dms/foo.kdl"` only requires creating <niriDir>/dms/foo.kdl.
{ niriDir, lib }:

let
  inherit (builtins)
    readDir
    readFile
    attrNames
    filter
    ;

  dmsDir = niriDir + "/dms";
  dmsFiles = attrNames (readDir dmsDir);
  kdlFiles = filter (name: lib.hasSuffix ".kdl" name) dmsFiles;

  fromList = map (name: ''include "dms/${name}"'') kdlFiles;
  toList = map (name: ''include "${dmsDir + "/${name}"}"'') kdlFiles;
in

builtins.replaceStrings fromList toList (readFile (niriDir + "/config.kdl"))
