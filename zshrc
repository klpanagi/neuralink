#!/usr/bin/zsh

export LANG=en_US.UTF-8
export BROWSER="firefox"
export TERMINAL="ghostty"
export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
export GOPATH=$HOME/go
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig
export SSH_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
export GITHUB_ACCESS_TOKEN_FILE="${HOME}/.github-access.token"

typeset -U PATH path
path=(
  "$HOME/.local/bin"
  "$HOME/.opencode/bin"
  "$GOPATH/bin"
  $path
)

typeset -U LD_LIBRARY_PATH
export LD_LIBRARY_PATH="${HOME}/.local/lib:${LD_LIBRARY_PATH}"

setopt prompt_subst
setopt correct
setopt auto_cd
setopt extended_glob
setopt no_beep
setopt interactive_comments
setopt glob_dots

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt append_history
setopt hist_expire_dups_first
setopt hist_fcntl_lock
setopt hist_ignore_all_dups
setopt hist_lex_words
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt share_history

DISABLE_AUTO_UPDATE="true"
DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="mm/dd/yyyy"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages
zstyle :omz:plugins:ssh-agent quiet yes
zstyle :omz:plugins:ssh-agent lazy no
zinit snippet OMZP::ssh-agent
# vi-mode: explicit cursor shape (lighter than OMZ vi-mode snippet)
function zle-keymap-select() {
  case $KEYMAP in
    vicmd)      echo -ne '\e[2 q' ;;  # block cursor
    viins|main) echo -ne '\e[6 q' ;;  # beam cursor
  esac
}
zle -N zle-keymap-select
function zle-line-init() { echo -ne '\e[6 q' }
zle -N zle-line-init
zinit snippet OMZP::pip
command -v docker >/dev/null 2>&1 && zinit snippet OMZP::docker

zinit ice wait lucid
zinit light kutsan/zsh-system-clipboard

zinit ice wait lucid
zinit light MichaelAquilina/zsh-you-should-use

zinit ice wait lucid
zinit light wfxr/forgit

zmodload zsh/terminfo
zmodload zsh/zpty

fpath+=~/.zfunc
autoload -Uz compinit && compinit
zinit cdreplay -q

zstyle ':completion:*' menu no
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' rehash true
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps -p $word -o comm,pid,ppid,user,%cpu,%mem,etime'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

forgit_log=glo
forgit_diff=gd
forgit_add=ga
forgit_reset_head=grh
forgit_restore=gcf
forgit_clean=gclean
forgit_stash_show=gss

export FORGIT_FZF_DEFAULT_OPTS="
--exact
--border
--cycle
--reverse
--height '80%'
"

bindkey '^a' autosuggest-accept
bindkey '^e' autosuggest-execute
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=38"

bindkey -v
bindkey -M viins 'jk' vi-cmd-mode
bindkey '^R' history-incremental-search-backward
bindkey '^W' backward-kill-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

typeset -g ZSH_SYSTEM_CLIPBOARD_TMUX_SUPPORT='true'
typeset -g ZSH_SYSTEM_CLIPBOARD_SELECTION='CLIPBOARD'

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

command -v nvim >/dev/null 2>&1 &&
  { export EDITOR="nvim"; alias vim="nvim" } || export EDITOR="vim"

export FZF_COMPLETION_TRIGGER='~~'
export FZF_COMPLETION_OPTS='+c -x'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

command -v fd >/dev/null 2>&1 &&
  _fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
  }

command -v fd >/dev/null 2>&1 &&
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }

_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf "$@" --preview 'eza --tree --color=always --icons {} 2>/dev/null || tree -C {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" ;;
  esac
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

ctrl-z-restore () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N ctrl-z-restore
bindkey '^Z' ctrl-z-restore

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

conda() {
  unfunction conda
  [ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
  conda "$@"
}

command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd --shell zsh)"

command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh)"

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

[ -f "${HOME}/.zsh_aliases" ] && source ~/.zsh_aliases
[ -f "${HOME}/.zsh_functions" ] && source ~/.zsh_functions
[ -f "${HOME}/.zshrc_platform" ] && source ~/.zshrc_platform
[ -f "${HOME}/.gcp/env.bash" ] && source ~/.gcp/env.bash
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

command -v fd >/dev/null 2>&1 || echo "[WARNING]: fd missing! Install: pacman -S fd"
command -v fzf >/dev/null 2>&1 || echo "[WARNING]: fzf missing! Install: pacman -S fzf"
command -v eza >/dev/null 2>&1 || echo "[WARNING]: eza missing! Install: pacman -S eza"
command -v starship >/dev/null 2>&1 || echo "[WARNING]: starship missing! Install: pacman -S starship"
