# 日常通用 CLI 工具（与具体开发活动无关）。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.zine.bundles.cli;
in
{
  options.zine.bundles.cli.enable = lib.mkEnableOption "通用 CLI 工具捆绑";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
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
      nvtopPackages.full
    ];
  };
}
