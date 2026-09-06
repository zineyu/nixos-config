# 日常通用 CLI 工具（与具体开发活动无关）；语言/编译器/构建工具见 packages/dev.nix。
{ pkgs, lib, ... }:

{
  home.packages =
    with pkgs;
    [
      bat
      bitwarden-cli
      btop
      chafa
      chezmoi
      curl
      eza
      fastfetch
      fd
      fzf
      hugo
      imagemagick
      jq
      just
      lnav
      ncdu
      pandoc
      pigz
      resvg
      ripgrep
      stow
      trash-cli
      tree
      unzip
      websocat
      zip
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      nvtopPackages.full
      wl-clipboard
    ];
}
