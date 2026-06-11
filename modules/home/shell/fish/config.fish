if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Nix
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end
if test -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.fish"
    source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.fish"
end

zoxide init fish | source
starship init fish | source
direnv hook fish | source

alias cl clear
alias ls 'eza --group-directories-first --icons=auto'
alias ll 'ls -lh'
alias lsa 'ls -a'
alias lt 'eza --tree --level=2 --long --icons --git'
alias lta 'lt -a'
alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
alias cd z
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'

set -gx TERM xterm-256color

export GO111MODULE=auto

# pnpm
set -gx PNPM_HOME "/home/zine/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# uv
fish_add_path "/home/zine/.local/bin"
fish_add_path -g -p ~/flutter/bin

# go
fish_add_path /usr/local/go/bin

# cargo/bin
source "$HOME/.cargo/env.fish"

# flutter
fish_add_path /opt/flutter/bin

fish_add_path "/home/zine/.local/bin"

fish_add_path /opt/stepai/earth/cmd

#conda
fish_add_path /opt/miniconda3/condabin


# fzf.fish
set fzf_preview_dir_cmd eza --all -lh --group-directories-first --icons=auto
fzf_configure_bindings --directory=\cf

set -g fish_greeting ''
fish_vi_key_bindings

mise activate fish | source

set -gx EDITOR nvim

set -x CONDA_PATH /data/miniconda3/bin/conda $HOME/miniconda3/bin/conda

function conda
    echo "Lazy loading conda upon first invocation..."
    functions --erase conda
    for conda_path in $CONDA_PATH
        if test -f $conda_path
            echo "Using Conda installation found in $conda_path"
            eval $conda_path "shell.fish" hook | source
            conda $argv
            return
        end
    end
    echo "No conda installation found in $CONDA_PATH"
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

set -x N_PREFIX "$HOME/n"
contains "$N_PREFIX/bin" $PATH; or set -a PATH "$N_PREFIX/bin" # Added by n-install (see http://git.io/n-install-repo).
/usr/bin/mise activate fish | source
