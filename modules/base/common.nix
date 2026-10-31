{ homeStateVersion, ... }:

{
  # 兼容版本由 host inventory（hosts/default.nix）按主机声明，
  # 通过 mkSystem 注入，不随 nixpkgs 更新自动提升。
  home.stateVersion = homeStateVersion;

  programs.home-manager.enable = true;
}
