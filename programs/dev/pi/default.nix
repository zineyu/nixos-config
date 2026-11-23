{
  inputs,
  pkgs,
  ...
}:

let
  extensionsDir = ./extensions;
  # promptsDir = ./prompts;

  linkDir =
    targetPrefix: dir:
    builtins.listToAttrs (
      map (name: {
        name = "${targetPrefix}/${name}";
        value.source = dir + "/${name}";
      }) (builtins.attrNames (builtins.readDir dir))
    );

  # 带 npm 运行时依赖的扩展要构建出 node_modules 再链接，覆盖同名源码目录的链接。
  builtExtensionDirs = {
    pi-fff = pkgs.callPackage ./extensions/pi-fff/package.nix { };
  };
  builtExtensionLinks = pkgs.lib.mapAttrs' (
    name: dir:
    pkgs.lib.nameValuePair ".pi/agent/extensions/${name}" {
      source = dir;
    }
  ) builtExtensionDirs;

  piPackage = inputs.pi.packages.${pkgs.stdenv.hostPlatform.system}.pi;
in
{
  config = {
    # home.file = linkDir ".pi/agent/extensions" extensionsDir // linkDir ".pi/agent/prompts" promptsDir;
    home.file = linkDir ".pi/agent/extensions" extensionsDir // builtExtensionLinks;
    home.packages = [ piPackage ];
  };
}
