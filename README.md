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
git clone https://github.com/sahashirshendu/nvimsf.git ~/.config.nvim
```

## Usage
Run neovim with `neovim`.
Learn the basics of (Neo)Vim by running `:Tutor`.
Just for info, to quit `neovim` enter `ZZ` or `:q`.
On first run, to sync the plugins, enter `:PackerSync`.

By default, the configuration has Language Server Protocol (LSP) set up, but not enabled.
To enable LSP, uncomment the LSP section of the Plugins function which also calls the `lsp_setup()` function.

#### Some Shortcuts used in this config:
| Shortcut  | Function     |
| --------- | ------------ |
|`Space + w`| Write file   |
|`Space + q`| Quit file    |
|`Space + s`| Sync plugins |
|`Space + c`| Comment      |
