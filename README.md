# .dotfiles

## Installation

```bash
git clone git@github.com:michalwachowicz/.dotfiles.git "$HOME/.dotfiles"
cd "$HOME/.dotfiles"
./install.sh
```

## Update workflow

- Make config changes in this repository (source of truth).
- Re-run `./install.sh` when adding new managed files/symlinks or on a new machine.

## Optional

- Use a different location than `$HOME/.dotfiles` by setting `DOTFILES_DIR` before running install:

```bash
DOTFILES_DIR="$HOME/somewhere-else" ./install.sh
```
