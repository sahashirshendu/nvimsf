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
or
```bash
git clone https://github.com/sahashirshendu/nvimsf.git ~/.config.nvim
```
or just download and extract the `.zip` of this repository to `~/.config/nvim`

## Usage
Run neovim with `neovim`.
Learn the basics of (Neo)Vim by running `:Tutor`.
Just for info, to quit `neovim` enter `ZZ` or `:q`.
On first run, to sync the plugins, enter `:Lazy sync`.

By default, the configuration has Language Server Protocol (LSP) set up, but not enabled.
To enable LSP, change `lsp` to `true` at the beginning of `init.lua`.

#### Some Shortcuts used in this config:
|  Shortcut  | Function     |
| ---------- | ------------ |
|    `,w`    | Write file   |
|    `,q`    | Quit file    |
|    `,s`    | Sync plugins |
|    `,k`    | Comment      |
