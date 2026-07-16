{ inputs, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        mkNixPak = inputs.nixpak.lib.nixpak {
          pkgs = prev;
          lib = prev.lib;
        };
      in
      {
        nixpaks = {
          qq = prev.callPackage ../../lib/nixpaks-qq.nix { inherit mkNixPak; };
          wechat = prev.callPackage ../../lib/nixpaks-wechat.nix { inherit mkNixPak; };
        };
      }
    )
  ];
}
