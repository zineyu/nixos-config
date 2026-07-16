{ inputs, ... }:
{
  nixpkgs.overlays = [
    (
      _final: prev:
      let
        mkNixPak = inputs.nixpak.lib.nixpak {
          pkgs = prev;
          inherit (prev) lib;
        };
      in
      {
        nixpaks = {
          qq = prev.callPackage ../../../lib/nixpaks-qq.nix { inherit mkNixPak; };
          wechat = prev.callPackage ../../../lib/nixpaks-wechat.nix { inherit mkNixPak; };
        };
      }
    )
  ];
}
