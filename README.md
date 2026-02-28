<div align="center">

```
  ███╗   ██╗███████╗██╗   ██╗██████╗  █████╗ ██╗      ██╗███╗   ██╗██╗  ██╗
  ████╗  ██║██╔════╝██║   ██║██╔══██╗██╔══██╗██║      ██║████╗  ██║██║ ██╔╝
  ██╔██╗ ██║█████╗  ██║   ██║██████╔╝███████║██║      ██║██╔██╗ ██║█████╔╝
  ██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██╔══██║██║      ██║██║╚██╗██║██╔═██╗
  ██║ ╚████║███████╗╚██████╔╝██║  ██║██║  ██║███████╗ ██║██║ ╚████║██║  ██╗
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
```

**Building a curated terminal environment is a rite of passage.**

Combining the speed of **Zsh**, the multitasking of **Tmux**, the power of **Neovim**, and the modern aesthetics of **Ghostty**.

Catppuccin Mocha · Vi-mode everywhere · Symlinked configs · One-command setup

</div>

---

## Quick Start

```bash
git clone git@github.com:klpanagi/neuralink.git ~/.neuralink
cd ~/.neuralink
./install.sh
```

The installer is interactive — select what you want, skip what you don't.

Existing configs are backed up to `~/.neuralink-backup/<timestamp>/` before symlinking.

## What's Inside

```
~/.neuralink/
├── zshrc              → ~/.zshrc
├── zsh_aliases        → ~/.zsh_aliases
├── zsh_functions      → ~/.zsh_functions
├── tmux.conf          → ~/.tmux.conf
├── ghostty_config     → ~/.config/ghostty/config
├── init.lua           → ~/.config/nvim/init.lua
├── starship.toml      → ~/.config/starship.toml
└── install.sh
```

All configs are **symlinked** — edit files in the repo, changes apply immediately. No re-install needed.

---

## Zsh

### Plugins & Tools

| Layer | Tool | Purpose |
|-------|------|---------|
| Plugin manager | [Zinit](https://github.com/zdharma-continuum/zinit) | Turbo-mode lazy loading |
| Completions | [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Fuzzy completion with previews |
| Suggestions | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like inline suggestions |
| Highlighting | [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | Real-time syntax coloring |
| Git | [forgit](https://github.com/wfxr/forgit) | Interactive git with fzf |
| Clipboard | [zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard) | Vi-mode yanks to system clipboard |
| Hints | [you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) | Reminds you of existing aliases |
| Prompt | [Starship](https://starship.rs) | Minimal, fast, Catppuccin Mocha palette |
| History | [Atuin](https://atuin.sh) | Searchable shell history across machines |
| Navigation | [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` |
| Search | [fzf](https://github.com/junegunn/fzf) + [fd](https://github.com/sharkdp/fd) | Fuzzy file finding |

### Keybindings

| Key | Action |
|-----|--------|
| `jk` | Exit insert → normal mode |
| `Ctrl+A` | Accept autosuggestion |
| `Ctrl+E` | Execute autosuggestion |
| `Ctrl+R` | Search history (Atuin) |
| `Ctrl+W` | Delete word backward (stops at `/`) |
| `Ctrl+Z` | Toggle foreground/background process |
| `Ctrl+←/→` | Jump word left/right |
| `~~` | Trigger fzf completion |
| `<` / `>` | Switch fzf-tab group in completion |

### Aliases

#### File Listing (eza)

| Alias | Command |
|-------|---------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | Long list with icons |
| `la` | Long list including hidden |
| `lt` | Sort by modified time |
| `lk` | Sort by size |
| `tree` / `tree1` / `tree2` / `tree3` | Tree view at depth 1–3 |

#### Git

| Alias | Command |
|-------|---------|
| `gst` | `git status -s` |
| `gc` | `git commit -v` |
| `gca` | `git commit -v --amend` |
| `gp` | `git push` |
| `gf` | `git fetch` |
| `gl` | `git log --oneline --graph` |
| `gd` / `gds` | `git diff` / `git diff --staged` |
| `grb` | `git rebase -i` |
| `ga` | forgit interactive add |
| `glo` | forgit interactive log |

#### Navigation

| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

#### System

| Alias | Command |
|-------|---------|
| `c` | `clear` |
| `myip` | Show public IP |
| `tcp` / `udp` | List active connections |
| `findps` | `pgrep -af` (find processes) |
| `catp` | `bat` (syntax-highlighted cat) |
| `htop` | `btop` |

---

## Tmux

### Features

| Feature | Detail |
|---------|--------|
| Prefix | `` ` `` (backtick) |
| Theme | [Catppuccin Mocha](https://github.com/catppuccin/tmux) with rounded windows |
| Session persistence | [resurrect](https://github.com/tmux-plugins/tmux-resurrect) + [continuum](https://github.com/tmux-plugins/tmux-continuum) (auto-save every 15m) |
| Navigation | [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) for seamless pane/vim splits |
| Session management | [sessionx](https://github.com/omerxx/tmux-sessionx) + fzf session picker |
| Git | Lazygit popup (`` `g ``) |
| Copy hints | [tmux-thumbs](https://github.com/fcsonline/tmux-thumbs) |
| Status bar | Session name (left), CPU + time (right), centered windows |

### Keybindings

All prefixed with `` ` `` (backtick) unless noted otherwise.

#### Splits & Windows

| Key | Action |
|-----|--------|
| `` `\ `` | Split horizontal |
| `` `- `` | Split vertical |
| `` `c `` | New window (inherits path) |
| `` `a `` | Last window |
| `` `← `` / `` `→ `` | Previous / next window |
| `` `X `` | Kill window |
| `` `Q `` | Kill session |

#### Pane Navigation & Management

| Key | Action |
|-----|--------|
| `` `h/j/k/l `` | Navigate panes (vim-style) |
| `` `H/J/K/L `` | Resize panes (±10) |
| `` `Tab `` | Cycle to next pane |
| `` `z `` | Zoom/unzoom current pane |
| `` `m `` | Mark pane (for join) |
| `` `M `` | Join marked pane here |

#### Sessions & Popups

| Key | Action |
|-----|--------|
| `` `g `` | Lazygit popup (80×80%) |
| `` `S `` | fzf session picker |
| `` `o `` | Sessionx |
| `` `C-p `` | Popup shell (60×40%) |

#### Copy Mode (vi-style)

| Key | Action |
|-----|--------|
| `` `P `` | Paste buffer |
| `v` | Begin selection |
| `y` | Copy selection |
| `r` | Toggle rectangle selection |
| `/` | Incremental search forward |
| `?` | Incremental search backward |
| `` `F `` | Thumbs (copy hints) |

#### Meta

| Key | Action |
|-----|--------|
| `` `r `` | Reload config |

---

## Ghostty

### Settings

| Setting | Value |
|---------|-------|
| Theme | Catppuccin Mocha |
| Font | JetBrains Mono, size 11, thickened, no-hinting |
| Opacity | 0.92 with blur, applied to cells too |
| Cursor | Block, no blink, inverted fg/bg |
| Contrast | 1.1 minimum |
| Unfocused splits | 0.85 opacity |
| Scrollback | 100,000 lines |
| Ligatures | Contextual alternates disabled, break at cursor |
| Window | State persistence, tabs at bottom, single GTK instance |

### Keybindings

#### Splits

| Key | Action |
|-----|--------|
| `Alt+D` | Split right |
| `Alt+Shift+D` | Split down |
| `Alt+W` | Close split |
| `Alt+H/J/K/L` | Navigate splits |
| `Alt+Shift+Enter` | Zoom/unzoom split |
| `Alt+Shift+E` | Equalize all splits |
| `Alt+Ctrl+Arrows` | Resize splits (±10) |

#### Tabs

| Key | Action |
|-----|--------|
| `Alt+T` | New tab |
| `Alt+1–5` | Go to tab |

#### Navigation & Display

| Key | Action |
|-----|--------|
| `Alt+Up/Down` | Jump to prev/next prompt |
| `Alt+=/−/0` | Font size increase/decrease/reset |
| `Alt+Enter` | Toggle fullscreen |

#### Utilities

| Key | Action |
|-----|--------|
| `Ctrl+Shift+V` | Paste from clipboard |
| `Alt+F` | Copy URL to clipboard |
| `Alt+Shift+S` | Dump scrollback to file |
| `Alt+Shift+I` | Terminal inspector |
| `Alt+Ctrl+R` | Reload config |

---

## Neovim

Single-file config (`init.lua`) with [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Leader key is `Space`.

### Plugins

| Plugin | Purpose |
|--------|---------|
| [catppuccin](https://github.com/catppuccin/nvim) | Colorscheme (Mocha) |
| [snacks.nvim](https://github.com/folke/snacks.nvim) | Dashboard, picker, notifier, indent guides, lazygit, terminal, statuscolumn, word highlighting |
| [blink.cmp](https://github.com/saghen/blink.cmp) | Completion engine (LSP, path, snippets, buffer) |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | LSP client configuration |
| [mason.nvim](https://github.com/williamboman/mason.nvim) | LSP server installer |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting, indent, incremental selection, textobjects |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keybinding popup guide |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git diff signs in gutter |
| [mini.pairs](https://github.com/echasnovski/mini.pairs) | Auto-close brackets and quotes |
| [mini.surround](https://github.com/echasnovski/mini.surround) | Add/change/delete surrounding pairs |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Format on save (stylua, black, prettier, gofmt, rustfmt) |
| [trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics list |
| [opencode.nvim](https://github.com/sudo-tee/opencode.nvim) | AI agent integration |

### LSP Servers (auto-installed via Mason)

`lua_ls` · `pyright` · `ts_ls` · `gopls` · `rust_analyzer` · `bashls` · `jsonls` · `yamlls`

### Keybindings

#### General

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `jk` | Exit insert mode |
| `Space w` | Save file |
| `Esc` | Clear search highlight |

#### LSP (active when language server attaches)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `Space rn` | Rename symbol |
| `Space ca` | Code action |
| `Space D` | Type definition |

#### Find (Snacks Picker)

| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fg` | Live grep |
| `Space fb` | Open buffers |
| `Space fh` | Help tags |
| `Space fr` | Recent files |
| `Space fs` | LSP symbols |

#### Git

| Key | Action |
|-----|--------|
| `Space gg` | Open Lazygit |
| `Space gb` | Git blame current line |

#### Buffers

| Key | Action |
|-----|--------|
| `Shift+H` | Previous buffer |
| `Shift+L` | Next buffer |
| `Space bd` | Delete buffer |

#### Windows

| Key | Action |
|-----|--------|
| `Ctrl+H/J/K/L` | Navigate windows |

#### Diagnostics

| Key | Action |
|-----|--------|
| `[d` / `]d` | Previous / next diagnostic |
| `Space e` | Show diagnostic float |
| `Space q` | Toggle Trouble diagnostics panel |

#### Treesitter

| Key | Action |
|-----|--------|
| `Ctrl+Space` | Start / expand incremental selection |
| `Backspace` | Shrink selection |
| `af` / `if` | Select around / inside function |
| `ac` / `ic` | Select around / inside class |
| `aa` / `ia` | Select around / inside parameter |
| `]m` / `[m` | Next / previous function |
| `]c` / `[c` | Next / previous class |

#### Surround (mini.surround)

| Key | Action |
|-----|--------|
| `sa` | Add surrounding |
| `sd` | Delete surrounding |
| `sr` | Replace surrounding |

#### OpenCode (AI Agent)

| Key | Action |
|-----|--------|
| `Space o` | OpenCode prefix (see which-key for submenu) |

---

## Install Script

The interactive installer supports **Arch/Manjaro** and **Debian/Ubuntu**.

```
╔══════════════════════════════════════════════════════════════════════╗
║  [1] Core              zsh, tmux, git, curl, wget                  ║
║  [2] CLI Tools         fzf, fd, eza, bat, dust, btop, neovim       ║
║  [3] Shell Enhancers   starship, zoxide, atuin, lazygit            ║
║  [4] Dev Tools         pyenv, fnm                                  ║
║  [5] Fonts             JetBrains Mono Nerd Font                    ║
║  [6] Symlink Configs   zshrc, tmux, ghostty, nvim, starship, etc.  ║
╚══════════════════════════════════════════════════════════════════════╝
```

Each component is optional. Already-installed tools are skipped. Platform-specific packaging quirks (like `fd-find` → `fd` on Debian) are handled automatically.

## Post-Install

1. Restart your terminal or run `exec zsh`
2. Open tmux and press `` `I `` to install tmux plugins
3. Open neovim — lazy.nvim auto-installs plugins, Mason auto-installs LSP servers
4. Zinit plugins auto-install on first zsh launch

## License

[MIT](LICENSE)
