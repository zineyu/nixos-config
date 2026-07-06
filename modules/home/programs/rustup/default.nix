{ pkgs, ... }:

{
  home.packages = [ pkgs.rustup ];

  # Provide the environment files that existing shell configs expect to source.
  home.file = {
    ".cargo/env".text = ''
      # Add cargo bin to PATH if not already present.
      case ":''${PATH}:" in
        *:"$HOME/.cargo/bin":*)
          ;;
        *)
          export PATH="$HOME/.cargo/bin:$PATH"
          ;;
      esac
    '';

    ".cargo/env.fish".text = ''
      if not string match -q -- $HOME/.cargo/bin $PATH
        set -gx PATH "$HOME/.cargo/bin" $PATH
      end
    '';
  };
}
