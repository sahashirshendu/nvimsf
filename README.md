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

### To use without LSP (Default):
```bash
cp init_min.lua init.lua
```
### To use with LSP (a wee bit heavier):
```bash
cp init_lsp.lua init.lua
```

#### Some Shortcuts used in this config:
| Shortcut  | Function     |
| --------- | ------------ |
|`Space + w`| Write file   |
|`Space + q`| Quit file    |
|`Space + s`| Sync plugins |
|`Space + c`| Comment      |

> **Issues :**
> Completion window too long.
