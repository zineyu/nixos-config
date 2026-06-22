{ ... }:

{
  imports = [
    ./git
    ./gnupg
    ./jj
    ./neovim
    ./kitty
    ./ghostty
    ./yazi
    ./zellij
    ./zed
    ./atuin
    ./mise
    ./zoxide
    ./direnv
    ./fontconfig
    ./npm
    ./devtools
    (
      { config, pkgs, ... }:
      let
        wrapGui = config.lib.nixGL.wrap;
      in
      {
        home.packages = with pkgs; [
          (wrapGui localsend)
          (wrapGui telegram-desktop)
          (wrapGui qbittorrent)
          (wrapGui vlc)
          (wrapGui gimp)
          (wrapGui dbeaver-bin)
          (wrapGui thunderbird)
          (wrapGui alacritty)
        ];
      }
    )
    ./aria2
    ./zen-browser
    ./yay
  ];
}
