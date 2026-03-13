#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

log() {
  printf "\n==> %s\n" "$1"
}

warn() {
  printf "\n[warn] %s\n" "$1"
}

exists() {
  command -v "$1" >/dev/null 2>&1
}

detect_os() {
  case "$(uname -s)" in
    Darwin) OS="macos" ;;
    Linux) OS="linux" ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}

install_homebrew() {
  if exists brew; then
    return
  fi

  log "Installing Homebrew"

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [ "$OS" = "macos" ]; then
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
      eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
    fi
  fi
}

ensure_brew_in_shell() {
  if ! exists brew; then
    warn "brew still not found in PATH after install attempt"
    return
  fi

  local shell_line=""
  if [ "$OS" = "macos" ]; then
    if [ -x /opt/homebrew/bin/brew ]; then
      shell_line="eval \"\$(/opt/homebrew/bin/brew shellenv)\""
    elif [ -x /usr/local/bin/brew ]; then
      shell_line="eval \"\$(/usr/local/bin/brew shellenv)\""
    fi
  else
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
      shell_line="eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\""
    elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
      shell_line="eval \"\$(\"\$HOME/.linuxbrew/bin/brew\" shellenv)\""
    fi
  fi

  if [ -n "$shell_line" ]; then
    touch "$HOME/.zprofile"
    if ! grep -Fq "$shell_line" "$HOME/.zprofile"; then
      log "Adding Homebrew shellenv to ~/.zprofile"
      printf '\n%s\n' "$shell_line" >> "$HOME/.zprofile"
    fi
  fi
}

install_packages() {
  if ! exists brew; then
    warn "Skipping package install because brew is unavailable"
    return
  fi

  if [ -f "$DOTFILES_DIR/brew/Brewfile" ]; then
    log "Installing shared packages from Brewfile"
    brew bundle --file="$DOTFILES_DIR/brew/Brewfile"
  fi

  if [ "$OS" = "macos" ] && [ -f "$DOTFILES_DIR/brew/Brewfile.macos" ]; then
    log "Installing macOS packages from Brewfile.macos"
    brew bundle --file="$DOTFILES_DIR/brew/Brewfile.macos"
  fi
}

install_npm_packages() {
  if ! exists npm; then
    warn "npm not found, skipping npm package install"
    return
  fi

  log "Installing npm packages globally"
  npm install -g neovim tree-sitter-cli
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Oh My Zsh already installed"
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"

  if [ -d "$tpm_dir" ]; then
    log "TPM already installed"
    return
  fi

  if ! exists git; then
    warn "git not found, skipping TPM installation"
    return
  fi

  log "Installing tmux plugin manager"
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
}

create_dirs() {
  log "Creating directories"
  mkdir -p "$HOME/.config"
}

symlink_file() {
  local source="$1"
  local target="$2"

  mkdir -p "$(dirname "$target")"
  ln -sfn "$source" "$target"
  echo "linked: $target -> $source"
}

symlink_configs() {
  log "Symlinking configs"

  [ -f "$DOTFILES_DIR/zsh/.zshrc" ] && symlink_file "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  [ -f "$DOTFILES_DIR/tmux/tmux.conf" ] && symlink_file "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  [ -f "$DOTFILES_DIR/.gitconfig" ] && symlink_file "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  [ -f "$DOTFILES_DIR/.ideavimrc" ] && symlink_file "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
  [ -d "$DOTFILES_DIR/nvim" ] && symlink_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
  [ -d "$DOTFILES_DIR/ghostty" ] && symlink_file "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
}

set_default_shell() {
  if ! exists zsh; then
    warn "zsh not found, skipping default shell change"
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [ "${SHELL:-}" = "$zsh_path" ]; then
    log "Default shell already set to zsh"
    return
  fi

  if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
    warn "$zsh_path is not listed in /etc/shells, skipping chsh"
    return
  fi

  log "Setting default shell to zsh"
  chsh -s "$zsh_path" || warn "Could not change shell automatically"
}

main() {
  detect_os
  log "Detected OS: $OS"

  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
  fi

  install_homebrew
  ensure_brew_in_shell
  install_packages
  install_npm_packages
  install_oh_my_zsh
  create_dirs
  symlink_configs
  install_tpm
  set_default_shell

  log "Done"
  echo "Restart your terminal."
  echo "Then run tmux and press prefix + I to install tmux plugins."
}

main "$@"
