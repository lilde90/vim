#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
Restore the shared macOS terminal environment from this repository.

Usage:
  ./setup-mac.sh
  DRY_RUN=1 ./setup-mac.sh
  TARGET_HOME=/Users/someone ./setup-mac.sh

What it restores:
  - Homebrew bootstrap (required for package installs)
  - tmux and python formulas
  - iTerm2 and font-maple-mono-nf-cn casks
  - Monaco nerd font zips (MonacoLigaturizedNerdFont.zip and friends) into ~/Library/Fonts
  - Oh My Zsh, Powerlevel10k, and Zsh plugins
  - copied ~/.vimrc, ~/.vim, ~/.tmux.conf, ~/.p10k.zsh, ~/.zshrc, ~/.zprofile
  - ~/.zshrc.local from zshrc.local.example if missing
  - iTerm2 preferences from com.googlecode.iterm2.plist

Environment knobs:
  TARGET_HOME  Override the dotfile destination home directory.
  DRY_RUN      Print commands without making changes when set to 1.

Notes:
  - Xcode Command Line Tools are required before Homebrew and git-based installs.
  - iTerm2 preferences are imported only for the current GUI user.
EOF
}

font_target_dir() {
  printf '%s\n' "${TARGET_HOME}/Library/Fonts"
}

ensure_xcode_clt() {
  if xcode-select -p >/dev/null 2>&1; then
    return 0
  fi

  warn "Xcode Command Line Tools are required before this script can continue."
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] xcode-select --install\n'
  else
    xcode-select --install || true
  fi
  warn "Finish the Xcode Command Line Tools installation, then rerun this script."
  exit 1
}

ensure_brew() {
  if have brew; then
    return 0
  fi

  log "Installing Homebrew"
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\n'
    return 0
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_brew_shellenv() {
  if ! have brew; then
    return 0
  fi

  eval "$("$(command -v brew)" shellenv)"
}

ensure_formula() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    log "Homebrew formula already installed: $formula"
    return 0
  fi

  log "Installing Homebrew formula: $formula"
  run brew install "$formula"
}

ensure_cask() {
  local cask="$1"
  if brew list --cask "$cask" >/dev/null 2>&1; then
    log "Homebrew cask already installed: $cask"
    return 0
  fi

  log "Installing Homebrew cask: $cask"
  run brew install --cask "$cask"
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

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    log "Keeping existing local shell overrides: $dest"
    return 0
  fi

  log "Creating local shell override template: $dest"
  run cp "$src" "$dest"
}

import_iterm2_prefs() {
  local plist="$REPO_DIR/com.googlecode.iterm2.plist"

  if [ ! -f "$plist" ]; then
    warn "Skipped iTerm2 preferences import because $plist is missing."
    return 0
  fi

  if [ "$TARGET_HOME" != "$HOME" ]; then
    warn "Skipped iTerm2 preferences import because TARGET_HOME differs from the logged-in HOME."
    return 0
  fi

  log "Importing iTerm2 preferences"
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] defaults import com.googlecode.iterm2 %q\n' "$plist"
  else
    defaults import com.googlecode.iterm2 "$plist"
  fi
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

    while IFS= read -r -d '' font_file; do
      log "Installing font $(basename "$font_file")"
      run cp -f "$font_file" "$fonts_dir/"
    done < <(find "$unpack_dir" -type f \( -iname '*.ttf' -o -iname '*.otf' \) -print0)
  done
}

main() {
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
  fi

  ensure_xcode_clt
  ensure_brew
  load_brew_shellenv

  log "Installing terminal dependencies"
  run brew tap homebrew/cask-fonts
  ensure_formula tmux
  ensure_formula python
  ensure_cask iterm2
  ensure_cask font-maple-mono-nf-cn
  install_monaco_nerd_fonts

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

  import_iterm2_prefs

  cat <<EOF

Done.

Next steps:
  1. Start iTerm2 and confirm both Maple Mono NF CN and MonacoLigaturizedNF fonts are available.
  2. Restart your shell or run: source "$TARGET_HOME/.zprofile" && source "$TARGET_HOME/.zshrc"
  3. Put machine-specific secrets, PATH tweaks, and aliases in "$TARGET_HOME/.zshrc.local".
  4. If you want the imported iTerm2 profile immediately, quit and reopen iTerm2 once.
EOF
}

main "$@"
