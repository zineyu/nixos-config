{
  inputs,
  pkgs,
  ...
}:

let
  extensionsDir = ./extensions;

  linkDir =
    targetPrefix: dir:
    builtins.listToAttrs (
      map (name: {
        name = "${targetPrefix}/${name}";
        value.source = dir + "/${name}";
      }) (builtins.attrNames (builtins.readDir dir))
    );
  piPackage = inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.pi;
in
{
  config = {
    home.file = linkDir ".pi/agent/extensions" extensionsDir;
    home.packages = [ piPackage ];
  };
}
