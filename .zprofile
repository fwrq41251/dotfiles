# Initialize Homebrew on Apple Silicon or Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Optional machine-specific login-shell integration.
[[ ! -r "$HOME/.zprofile.local" ]] || source "$HOME/.zprofile.local"
