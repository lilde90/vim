#!/usr/bin/env bash
# Copyright 2026 lilde90. All Rights Reserved.
# Author: Pan Li (panli.me@gmail.com)
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Note: Assuming this script is in scripts/ and dotfiles are in the parent directory
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_HOME="${TARGET_HOME:-$HOME}"
DRY_RUN="${DRY_RUN:-0}"

log() {
  printf '==> %s\n' "$*"
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run]'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
    return 0
  fi

  "$@"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

usage() {
  cat <<'EOF'
Restore the shared terminal environment from this repository on Ubuntu.

Usage:
  ./setup-ubuntu.sh
  DRY_RUN=1 ./setup-ubuntu.sh
  TARGET_HOME=/home/someone ./setup-ubuntu.sh

What it restores:
  - Core packages via apt (tmux, zsh, git, curl, etc.)
  - Monaco nerd font zips into ~/.local/share/fonts
  - Oh My Zsh, Powerlevel10k, and Zsh plugins
  - copied ~/.vimrc, ~/.vim, ~/.tmux.conf, ~/.p10k.zsh, ~/.zshrc, ~/.zprofile
  - ~/.zshrc.local from zshrc.local.example if missing

Environment knobs:
  TARGET_HOME  Override the dotfile destination home directory.
  DRY_RUN      Print commands without making changes when set to 1.
EOF
}

font_target_dir() {
  printf '%s\n' "${TARGET_HOME}/.local/share/fonts"
}

ensure_apt_packages() {
  local pkgs=(
    build-essential
    curl
    git
    tmux
    zsh
    unzip
    python3
    python3-pip
    fontconfig
    vim
  )

  log "Ensuring core packages are installed via apt"
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] sudo apt-get update\n'
    printf '[dry-run] sudo apt-get install -y %s\n' "${pkgs[*]}"
    return 0
  fi

  sudo apt-get update
  sudo apt-get install -y "${pkgs[@]}"
}

clone_or_update_repo() {
  local url="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -d "$dest/.git" ]; then
    log "Updating $(basename "$dest")"
    run git -C "$dest" pull --ff-only
    return 0
  fi

  log "Cloning $(basename "$dest")"
  run git clone --depth=1 "$url" "$dest"
}

backup_existing() {
  local path="$1"

  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    return 0
  fi

  local backup="${path}.bak.$(date +%Y%m%d-%H%M%S)"
  log "Backing up existing $(basename "$path") to $backup"
  run mv "$path" "$backup"
}

copy_repo_path() {
  local src="$1"
  local dest="$2"

  if [ ! -e "$src" ]; then
    warn "Source path $src does not exist, skipping."
    return 0
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_existing "$dest"
  fi

  if [ -d "$src" ]; then
    log "Copying directory $src -> $dest"
    run cp -R "$src" "$dest"
  else
    log "Copying file $src -> $dest"
    run cp "$src" "$dest"
  fi
}

write_local_example_if_missing() {
  local src="$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    warn "Local example $src not found, skipping template creation."
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    log "Keeping existing local shell overrides: $dest"
    return 0
  fi

  log "Creating local shell override template: $dest"
  run cp "$src" "$dest"
}

install_monaco_nerd_fonts() {
  local fonts_dir
  fonts_dir="$(font_target_dir)"
  local cache_dir="$REPO_DIR/.cache/monaco-nerd-font-v0.2.1"
  local base_url="https://github.com/thep0y/monaco-nerd-font/releases/download/v0.2.1"
  local assets=(
    "MonacoLigaturizedNerdFont.zip"
    "MonacoLigaturizedNerdFontMono.zip"
    "MonacoNerdFont.zip"
    "MonacoNerdFontMono.zip"
  )

  log "Installing Monaco Nerd Font release assets into $fonts_dir"
  run mkdir -p "$fonts_dir"
  run mkdir -p "$cache_dir"

  local asset zip_path unpack_dir
  for asset in "${assets[@]}"; do
    zip_path="$cache_dir/$asset"
    unpack_dir="$cache_dir/${asset%.zip}"

    if [ ! -f "$zip_path" ]; then
      log "Downloading $asset"
      run curl -L --fail --output "$zip_path" "$base_url/$asset"
    else
      log "Reusing downloaded font archive: $asset"
    fi

    run rm -rf "$unpack_dir"
    run mkdir -p "$unpack_dir"
    log "Unpacking $asset"
    run unzip -oq "$zip_path" -d "$unpack_dir"

    if [ "$DRY_RUN" = "1" ]; then
      log "Would install unpacked font files from $unpack_dir into $fonts_dir"
      continue
    fi

    find "$unpack_dir" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print0 | while IFS= read -r -d '' font_file; do
      log "Installing font $(basename "$font_file")"
      run cp -f "$font_file" "$fonts_dir/"
    done
  done

  log "Updating font cache"
  run fc-cache -fv
}

ensure_zsh_default() {
  if [ "${SHELL##*/}" = "zsh" ]; then
    return 0
  fi

  log "Changing default shell to zsh"
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] chsh -s "$(which zsh)"\n'
  else
    run sudo chsh -s "$(which zsh)" "$USER"
  fi
}

main() {
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
  fi

  ensure_apt_packages

  log "Installing terminal dependencies"
  install_monaco_nerd_fonts
  # Note: font-maple-mono-nf-cn was a brew cask, we might need a manual download for it if desired.
  # For now, following the "monaco" example which is explicitly handled in the script.

  local ohmyzsh_dir="$TARGET_HOME/.oh-my-zsh"
  local custom_dir="$ohmyzsh_dir/custom"
  local themes_dir="$custom_dir/themes"
  local plugins_dir="$custom_dir/plugins"

  clone_or_update_repo https://github.com/ohmyzsh/ohmyzsh.git "$ohmyzsh_dir"
  clone_or_update_repo https://github.com/romkatv/powerlevel10k.git "$themes_dir/powerlevel10k"
  clone_or_update_repo https://github.com/zsh-users/zsh-autosuggestions.git "$plugins_dir/zsh-autosuggestions"
  clone_or_update_repo https://github.com/zsh-users/zsh-completions.git "$plugins_dir/zsh-completions"
  clone_or_update_repo https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugins_dir/zsh-syntax-highlighting"

  log "Copying shared dotfiles"
  copy_repo_path "$REPO_DIR/vimrc" "$TARGET_HOME/.vimrc"
  copy_repo_path "$REPO_DIR/vim" "$TARGET_HOME/.vim"
  copy_repo_path "$REPO_DIR/tmux.conf" "$TARGET_HOME/.tmux.conf"
  copy_repo_path "$REPO_DIR/p10k.zsh" "$TARGET_HOME/.p10k.zsh"
  copy_repo_path "$REPO_DIR/shell/zshrc" "$TARGET_HOME/.zshrc"
  copy_repo_path "$REPO_DIR/shell/zprofile" "$TARGET_HOME/.zprofile"
  write_local_example_if_missing "$REPO_DIR/shell/zshrc.local.example" "$TARGET_HOME/.zshrc.local"

  ensure_zsh_default

  cat <<EOF

Done.

Next steps:
  1. Restart your terminal or logout/login for shell changes to take effect.
  2. Confirm font installation by checking your terminal settings for Monaco Nerd Font.
  3. Restart your shell or run: source "$TARGET_HOME/.zprofile" && source "$TARGET_HOME/.zshrc"
  4. Put machine-specific secrets, PATH tweaks, and aliases in "$TARGET_HOME/.zshrc.local".
EOF
}

main "$@"#
