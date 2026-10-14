export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Optional environment overrides, including non-interactive shells.
[[ ! -r "$HOME/.zshenv.local" ]] || source "$HOME/.zshenv.local"
