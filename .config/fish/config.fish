if status is-interactive
	# Commands to run in interactive sessions can go here
end

# aliases
alias c "clear"
alias ls "eza --icons"

alias gst "git status"
alias ga "git add"
alias gcmsg "git commit -m"
alias gl "git pull"
alias gp "git push"
alias gf "git fetch"

alias hx "helix"
alias .. "cd .."

# env
set -gx EDITOR nvim

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/.cargo/bin $PATH
set -gx PATH ~/.scripts $PATH
set -gx PATH ~/.opam/default/bin $PATH
set -gx PATH ~/go/bin $PATH

# source /opt/asdf-vm/asdf.fish
# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

fish_vi_key_bindings

oh-my-posh init fish --config $HOME/.config/ohmyposh/config.toml | source

rerender_on_bind_mode_change
set_poshcontext
source_posh
