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

Combining the speed of **Zsh**, the multitasking of **Tmux**, and the modern aesthetics of **Ghostty**.

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
└── install.sh
```

All configs are **symlinked** — edit files in the repo, changes apply immediately. No re-install needed.

## The Stack

### Zsh

| Layer | Tool | Purpose |
|-------|------|---------|
| Plugin manager | [Zinit](https://github.com/zdharma-continuum/zinit) | Turbo-mode lazy loading |
| Completions | [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Fuzzy completion with previews |
| Suggestions | [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like inline suggestions |
| Highlighting | [fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting) | Real-time syntax coloring |
| Git | [forgit](https://github.com/wfxr/forgit) | Interactive git with fzf |
| Clipboard | [zsh-system-clipboard](https://github.com/kutsan/zsh-system-clipboard) | Vi-mode yanks to system clipboard |
| Hints | [you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) | Reminds you of existing aliases |
| Prompt | [Starship](https://starship.rs) | Minimal, fast, customizable |
| History | [Atuin](https://atuin.sh) | Searchable shell history across machines |
| Navigation | [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` |
| Search | [fzf](https://github.com/junegunn/fzf) + [fd](https://github.com/sharkdp/fd) | Fuzzy file finding |

### Tmux

| Feature | Detail |
|---------|--------|
| Prefix | `` ` `` (backtick) |
| Theme | [Catppuccin Mocha](https://github.com/catppuccin/tmux) with rounded windows |
| Session persistence | [resurrect](https://github.com/tmux-plugins/tmux-resurrect) + [continuum](https://github.com/tmux-plugins/tmux-continuum) (auto-save every 15m) |
| Navigation | [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) for seamless pane/vim splits |
| Session management | [sessionx](https://github.com/omerxx/tmux-sessionx) + fzf session picker |
| Git | Lazygit popup (`` `g ``) |
| Copy hints | [tmux-thumbs](https://github.com/fcsonline/tmux-thumbs) |

### Ghostty

| Setting | Value |
|---------|-------|
| Theme | Catppuccin Mocha |
| Opacity | 0.92 with blur |
| Cursor | Block, no blink, inverted fg/bg |
| Splits | `Super+D` / `Super+Shift+D` |
| Split nav | `Super+Ctrl+H/J/K/L` |

## Keybindings

### Zsh

| Key | Action |
|-----|--------|
| `jk` | Exit insert → normal mode |
| `Ctrl+A` | Accept autosuggestion |
| `Ctrl+E` | Execute autosuggestion |
| `Ctrl+R` | Search history |
| `Ctrl+W` | Delete word backward |
| `Ctrl+Z` | Toggle foreground/background process |
| `Ctrl+←/→` | Jump word left/right |
| `~~` | Trigger fzf completion |

### Tmux

| Key | Action |
|-----|--------|
| `` `\ `` | Split horizontal |
| `` `- `` | Split vertical |
| `` `h/j/k/l `` | Navigate panes |
| `` `H/J/K/L `` | Resize panes (±10) |
| `` `c `` | New window |
| `` `a `` | Last window |
| `` `Tab `` | Next pane |
| `` `g `` | Lazygit popup |
| `` `S `` | fzf session picker |
| `` `o `` | Sessionx |
| `` `F `` | Thumbs (copy hints) |
| `` `X `` | Kill window |
| `` `Q `` | Kill session |
| `` `r `` | Reload config |

## Aliases

### File Listing (eza)

| Alias | Command |
|-------|---------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | Long list with icons |
| `la` | Long list including hidden |
| `lt` | Sort by modified time |
| `lk` | Sort by size |
| `tree` / `tree1` / `tree2` / `tree3` | Tree view at depth 1–3 |

### Git

| Alias | Command |
|-------|---------|
| `gst` | `git status -s` |
| `gc` | `git commit -v` |
| `gp` | `git push` |
| `gf` | `git fetch` |
| `gl` | `git log --oneline --graph` |
| `gd` / `gds` | `git diff` / `git diff --staged` |
| `ga` | forgit interactive add |
| `glo` | forgit interactive log |

### System

| Alias | Command |
|-------|---------|
| `c` | `clear` |
| `myip` | Show public IP |
| `tcp` / `udp` | List active connections |
| `catp` | `bat` (syntax-highlighted cat) |
| `htop` | `btop` |

## Install Script

The interactive installer supports **Arch/Manjaro** and **Debian/Ubuntu**.

```
╔══════════════════════════════════════════════╗
║  [1] Core              zsh, tmux, git        ║
║  [2] CLI Tools         fzf, fd, eza, bat ... ║
║  [3] Shell Enhancers   starship, zoxide ...  ║
║  [4] Dev Tools         pyenv, fnm            ║
║  [5] Fonts             JetBrains Mono NF     ║
║  [6] Symlink Configs   all config files      ║
╚══════════════════════════════════════════════╝
```

Each component is optional. Already-installed tools are skipped. Platform-specific packaging quirks (like `fd-find` → `fd` on Debian) are handled automatically.

## Post-Install

1. Restart your terminal or run `exec zsh`
2. Open tmux and press `` `I `` to install tmux plugins
3. Zinit plugins auto-install on first launch

## License

[MIT](LICENSE)
