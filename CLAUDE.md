# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal dotfiles repository — shared Vim, tmux, Zsh, and iTerm2 configuration deployed to new machines via setup scripts. Not an application; there is no build or package manager.

## Testing changes

```bash
# Validate setup-mac.sh syntax and run integration checks
bash tests/test_setup_mac.sh

# Dry-run the Mac setup to see what it would do without touching the system
DRY_RUN=1 ./scripts/setup-mac.sh

# Dry-run the Ubuntu setup
DRY_RUN=1 ./scripts/setup-ubuntu.sh
```

The test script checks syntax (`bash -n`), verifies the `--help` output covers all key features, and does a full dry-run to catch errors. It also asserts that dotfiles are **copied** (not symlinked) — this was an intentional refactor in `2e35484`.

## Architecture

### How dotfiles reach `$HOME`

The setup scripts (`setup-mac.sh`, `setup-ubuntu.sh`) copy files from the repo into `$HOME`:

- `vimrc` → `~/.vimrc`
- `vim/` → `~/.vim`
- `tmux.conf` → `~/.tmux.conf`
- `p10k.zsh` → `~/.p10k.zsh`
- `shell/zshrc` → `~/.zshrc`
- `shell/zprofile` → `~/.zprofile`
- `shell/zshrc.local.example` → `~/.zshrc.local` (only if absent)

Both scripts use the same pattern: `DRY_RUN` env var gates all destructive operations, `TARGET_HOME` overrides the destination. Helper functions (`log`, `warn`, `run`, `backup_existing`, `copy_repo_path`, `clone_or_update_repo`) are duplicated between the two scripts rather than shared in a library — keep them in sync manually.

### Vim plugin management

Plugins live in `vim/bundle/` and are loaded by NeoBundle (the plugin manager itself is `vim/bundle/neobundle.vim`). The `vimrc` configures NERDTree, CtrlP, Syntastic, Fugitive, SnipMate, vim-fugitive, and OmniCpp. Keyboard shortcuts are defined at the bottom of `vimrc`.

### Clipboard integration chain

The mouse-selection-to-clipboard logic in `vimrc` (`CopyTextToClipboard`) tries strategies in order: tmux buffer → pbcopy (macOS) → wl-copy (Wayland) → xclip (X11) → OSC 52 escape sequences (terminal passthrough). This chain is a key design decision — when modifying clipboard behavior, the fallback order matters.

### Shell config loading order

`shell/zprofile` initializes Homebrew shell environment. `shell/zshrc` sources Oh My Zsh, loads the Powerlevel10k theme, and enables plugins (zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting). Machine-specific overrides go in `~/.zshrc.local`, which is created from the example file on first setup but never overwritten on subsequent runs.

### Repository naming

Despite the repo being called `vim`, it covers tmux, Zsh, iTerm2, and fonts. The setup scripts are the entry points — `setup-mac.sh` is the primary one that gets the most maintenance.
