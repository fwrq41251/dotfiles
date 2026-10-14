#!/bin/bash
set -euo pipefail

dotfiles_target=${DOTFILES_TARGET_HOME:-$HOME}
dotfiles_git_dir=${DOTFILES_GIT_DIR:-$dotfiles_target/.cfg}
dotfiles_repo=https://github.com/fwrq41251/dotfiles.git
install_dependencies=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --repo) dotfiles_repo=${2:?Missing repository URL}; shift 2 ;;
        --dependencies) install_dependencies=true; shift ;;
        *) echo "Usage: $0 [--repo URL] [--dependencies]" >&2; exit 2 ;;
    esac
done

config_git() {
    git -C "$dotfiles_target" --git-dir="$dotfiles_git_dir" --work-tree="$dotfiles_target" "$@"
}

mkdir -p "$dotfiles_target"
if [[ ! -e "$dotfiles_git_dir" ]]; then
    git clone --bare "$dotfiles_repo" "$dotfiles_git_dir"
fi
config_git rev-parse --verify HEAD >/dev/null

# Check every destination first. Never overwrite a different local file.
conflict=false
while IFS= read -r -d '' entry; do
    metadata=${entry%%$'\t'*}
    file=${entry#*$'\t'}
    mode=${metadata%% *}
    if [[ "$mode" != 100644 && "$mode" != 100755 ]]; then
        echo "Unsupported entry: $file ($mode)" >&2
        exit 1
    fi
    destination="$dotfiles_target/$file"
    parent=$(dirname "$destination")
    while [[ "$parent" != "$dotfiles_target" && "$parent" != / ]]; do
        if [[ -L "$parent" ]] || { [[ -e "$parent" ]] && [[ ! -d "$parent" ]]; }; then
            echo "Conflicting parent: $parent" >&2; conflict=true; break
        fi
        parent=$(dirname "$parent")
    done
    if [[ -L "$destination" ]] || { [[ -e "$destination" ]] &&
        { [[ ! -f "$destination" ]] || ! config_git show "HEAD:$file" | cmp -s - "$destination"; }; }; then
        echo "Existing file differs: $destination" >&2
        conflict=true
    fi
done < <(config_git ls-tree -rz HEAD)
if $conflict; then
    echo "Move the listed conflicts to a backup location, then rerun." >&2
    exit 1
fi
config_git checkout HEAD -- .
config_git config status.showUntrackedFiles no
config_git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'

if $install_dependencies; then
    # These pins match the previously installed dependency versions.
    install_repository() {
        local url=$1 destination=$2 revision=$3
        if [[ -e "$destination" || -L "$destination" ]]; then
            echo "Preserving existing dependency: $destination"
            return
        fi
        mkdir -p "$(dirname "$destination")"
        git clone "$url" "$destination"
        git -C "$destination" checkout --detach "$revision"
    }
    install_repository https://github.com/doomemacs/doomemacs.git \
        "$dotfiles_target/.config/emacs" 539db7daf80deb6965870e90af0544a608603e25
    install_repository https://github.com/ohmyzsh/ohmyzsh.git \
        "$dotfiles_target/.oh-my-zsh" 083c339e0622bfc144b66ebf1a2e8dbe7d2ada0d
    install_repository https://github.com/romkatv/powerlevel10k.git \
        "$dotfiles_target/.oh-my-zsh/custom/themes/powerlevel10k" 36f3045d69d1ba402db09d09eb12b42eebe0fa3b
    install_repository https://github.com/tmux-plugins/tpm.git \
        "$dotfiles_target/.tmux/plugins/tpm" 99469c4a9b1ccf77fade25842dc7bafbc8ce9946
fi
echo "Dotfiles restored. See .config/dotfiles/README.md for remaining setup."
