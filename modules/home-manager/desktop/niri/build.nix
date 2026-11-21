# Build a derivation containing the niri config file and the dms/ include directory.
# The config file uses relative include paths so that DMS can recognize which of its
# files are imported.
{ pkgs, niriDir }:

pkgs.stdenvNoCC.mkDerivation {
  name = "niri-config";
  src = niriDir;
  nativeBuildInputs = [ pkgs.niri ];
  installPhase = ''
    cp -r $src $out
    niri validate -c $out/config.kdl
  '';
}
