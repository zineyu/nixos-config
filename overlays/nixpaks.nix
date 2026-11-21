{ inputs }:
# nixpak 包装不引用 final，_ 前缀满足 deadnix。
_final: prev:
let
  mkNixPak = inputs.nixpak.lib.nixpak {
    pkgs = prev;
    inherit (prev) lib;
  };
in
{
  nixpaks = {
    qq = prev.callPackage ./nixpaks/qq.nix { inherit mkNixPak; };
    wechat = prev.callPackage ./nixpaks/wechat.nix { inherit mkNixPak; };
  };
}
