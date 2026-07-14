{
  config,
  ...
}:

{
  programs.fish = {
    enable = true;

    shellAliases = {
      cl = "clear";
      ls = "eza --group-directories-first --icons=auto";
      ll = "ls -lh";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "lt -a";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      fabric = "fabric-ai";
    };

    shellInit = ''
      # Nix daemon environment (not provided by Home Manager).
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end
    '';

    interactiveShellInit = ''
      # fzf.fish
      set fzf_preview_dir_cmd eza --all -lh --group-directories-first --icons=auto
      fzf_configure_bindings --directory=\cf

      set -g fish_greeting '''
      fish_vi_key_bindings

      contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin"
      devenv hook fish | source
    '';

    functions = {
      conda = ''
        echo "Lazy loading conda upon first invocation..."
        functions --erase conda
        set -l CONDA_PATH /data/miniconda3/bin/conda $HOME/miniconda3/bin/conda
        for conda_path in $CONDA_PATH
          if test -f $conda_path
            echo "Using Conda installation found in $conda_path"
            eval $conda_path "shell.fish" hook | source
            conda $argv
            return
          end
        end
        echo "No conda installation found in $CONDA_PATH"
      '';

      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        command yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };
  };

  home.sessionVariables = {
    TERM = "xterm-256color";
    GO111MODULE = "auto";
    EDITOR = "nvim";
    N_PREFIX = "$HOME/n";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  home.sessionPath = [
    "$PNPM_HOME"
    "$HOME/.local/bin"
    "$HOME/flutter/bin"
    "/usr/local/go/bin"
    "/opt/flutter/bin"
    "/opt/stepai/earth/cmd"
    "/opt/miniconda3/condabin"
  ];

  # Static fish configuration that is not yet expressible through Home Manager's
  # native options: third-party plugin files, themes, and universal variables.
  xdg.configFile = {
    "fish/completions" = {
      source = ./fish/completions;
      recursive = true;
    };
    "fish/conf.d" = {
      source = ./fish/conf.d;
      recursive = true;
    };
    "fish/functions" = {
      source = ./fish/functions;
      recursive = true;
    };
    "fish/themes" = {
      source = ./fish/themes;
      recursive = true;
    };
    "fish/fish_plugins".source = ./fish/fish_plugins;
    "fish/fish_variables".source = ./fish/fish_variables;
  };
}
