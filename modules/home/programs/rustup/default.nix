{ pkgs, ... }:

{
  home.packages = [ pkgs.rustup ];

  # Add cargo bin to PATH via Home Manager's session path so all shells inherit
  # it without per-shell environment files.
  home.sessionPath = [ "$HOME/.cargo/bin" ];
}
