# NeoVim Configuration

## Installation
Install `neovim` with:
```bash
sudo pacman -S neovim # Arch and derivatives
sudo apt install neovim # Debian and derivatives
sudo dnf install -y neovim python3-neovim # Fedora
```
For details, see: [Installing NeoVim](https://github.com/neovim/neovim/wiki/Installing-Neovim)

For installing the config,
```bash
git clone https://gitlab.com/shirshendusaha/nvimsf.git ~/.config.nvim
```

## Usage
Run neovim with `neovim`.
Learn the basics of (Neo)Vim by running `:Tutor`.
Just for info, to quit `neovim` enter `ZZ` or `:q`.
On first run, to sync the plugins, enter `:PackerSync`.

*To use with LSP (a wee bit heavier)*, uncomment the CMP and LSP sections in plugins functions and the last two lines of init.lua that source CMP and LSP configs.

#### Some Shortcuts used in this config:
| Shortcut  | Function     |
| --------- | ------------ |
|`Space + w`| Write file   |
|`Space + q`| Quit file    |
|`Space + s`| Sync plugins |
|`Space + c`| Comment      |

> **Issues :**
> Completion window too long.
