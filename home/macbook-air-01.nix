# macbook-air-01 的 Home Manager 组织文件：软件开关表与机器专属包。
{ pkgs, ... }:

{
  # 平台无关的 HM 基础层（modules/base）与 programs 由 lib/mkSystem.nix 接入；
  # 本文件只保留开关表与机器专属包。
  zine.programs = {
    # shell
    fish.enable = true;
    bash.enable = true;
    starship.enable = true;

    # terminal
    kitty.enable = true;
    atuin.enable = true;
    yazi.enable = true;
    zellij.enable = true;
    zoxide.enable = true;

    # dev
    git.enable = true;
    jujutsu.enable = true;
    mise.enable = true;
    devenv.enable = true;
    npm.enable = true;
    vscode.enable = true;
    dbeaver.enable = true;
    nixvim.enable = true;
    zed-editor.enable = true;
    fabric.enable = true;
    pi.enable = true;

    buf.enable = true;
    bun.enable = true;
    clang.enable = true;
    cmake.enable = true;
    codegraph.enable = true;
    dart-sass.enable = true;
    dsh.enable = true;
    gcc.enable = true;
    github-cli.enable = true;
    gnumake.enable = true;
    go.enable = true;
    jj-bond.enable = true;
    lazyjj.enable = true;
    lazygit.enable = true;
    llvm.enable = true;
    maven.enable = true;
    mold.enable = true;
    ninja.enable = true;
    pip.enable = true;
    python3.enable = true;
    rustup.enable = true;
    stylua.enable = true;
    tree-sitter.enable = true;
    uv.enable = true;

    # gui
    rustdesk.enable = true;
    dbx-desktop.enable = true;
    zen-browser.enable = true;

    # misc
    gpg.enable = true;
    karabiner-elements.enable = true;
    ssh.enable = true;
    sops.enable = true;

    bat.enable = true;
    bitwarden-cli.enable = true;
    btop.enable = true;
    chafa.enable = true;
    chezmoi.enable = true;
    curl.enable = true;
    eza.enable = true;
    fastfetch.enable = true;
    fd.enable = true;
    fzf.enable = true;
    hugo.enable = true;
    imagemagick.enable = true;
    jq.enable = true;
    just.enable = true;
    lnav.enable = true;
    ncdu.enable = true;
    nvtop.enable = true;
    pandoc.enable = true;
    pigz.enable = true;
    resvg.enable = true;
    ripgrep.enable = true;
    stow.enable = true;
    trash-cli.enable = true;
    tree.enable = true;
    unzip.enable = true;
    websocat.enable = true;
    zip.enable = true;
  };

  # macbook-air-01 专属的代理内核 CLI（LaunchDaemon 与配置见 modules/darwin/mihomo）。
  home.packages = [ pkgs.mihomo ];
}
