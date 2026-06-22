{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    atuin
    bitwarden-cli
    buf
    bun
    ccache
    chafa
    chezmoi
    (lib.setPrio 20 clang)
    cmake
    dart-sass
    github-cli
    go
    hugo
    imagemagick
    lazyjj
    llvm
    maven
    mise
    mold
    ninja
    opencode
    pandoc
    pigz
    resvg
    stow
    trash-cli
    tree
    uv
    websocat
    zip
    zoxide
  ];
}
