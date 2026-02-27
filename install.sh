#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  neuralink — interactive installer                                       ║
# ║  Sets up zsh + tmux + ghostty with symlinked configs                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.neuralink-backup/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/tmp/neuralink-install-$(date +%Y%m%d_%H%M%S).log"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Logging ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[·]${NC} $*"; }
success() { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*"; }
step()    { echo -e "\n${MAGENTA}${BOLD}═══ $* ═══${NC}\n"; }
dim()     { echo -e "${DIM}    $*${NC}"; }

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }

# ── Helpers ───────────────────────────────────────────────────────────────────
ask() {
    local prompt="$1" default="${2:-y}"
    local hint
    if [[ "$default" == "y" ]]; then hint="[Y/n]"; else hint="[y/N]"; fi
    echo -en "${CYAN}[?]${NC} ${prompt} ${DIM}${hint}${NC} " > /dev/tty
    read -r reply < /dev/tty
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy] ]]
}

cmd_exists() { command -v "$1" &>/dev/null; }

# ── Platform Detection ────────────────────────────────────────────────────────
detect_platform() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        case "$ID" in
            arch|manjaro|endeavouros|garuda|cachyos)
                PLATFORM="arch"
                PKG_MGR="pacman"
                ;;
            ubuntu|debian|pop|linuxmint|elementary|zorin)
                PLATFORM="debian"
                PKG_MGR="apt"
                ;;
            *)
                # Try ID_LIKE as fallback
                case "${ID_LIKE:-}" in
                    *arch*)  PLATFORM="arch";   PKG_MGR="pacman" ;;
                    *debian*|*ubuntu*) PLATFORM="debian"; PKG_MGR="apt" ;;
                    *)
                        error "Unsupported distro: $ID"
                        error "This installer supports Arch-based and Debian-based distros."
                        exit 1
                        ;;
                esac
                ;;
        esac
    else
        error "Cannot detect platform (/etc/os-release not found)"
        exit 1
    fi
}

# ── Package Installers ────────────────────────────────────────────────────────
pkg_install() {
    local name="$1"
    log "Installing package: $name"
    case "$PKG_MGR" in
        pacman) sudo pacman -S --noconfirm --needed "$name" >> "$LOG_FILE" 2>&1 ;;
        apt)    sudo apt-get install -y "$name" >> "$LOG_FILE" 2>&1 ;;
    esac
}

# Check if an AUR helper is available (arch only)
aur_helper=""
detect_aur_helper() {
    for helper in paru yay; do
        if cmd_exists "$helper"; then
            aur_helper="$helper"
            return
        fi
    done
}

aur_install() {
    local name="$1"
    if [[ -z "$aur_helper" ]]; then
        warn "No AUR helper found (paru/yay). Skipping AUR package: $name"
        warn "Install paru or yay first, then re-run."
        return 1
    fi
    log "Installing AUR package: $name"
    "$aur_helper" -S --noconfirm --needed "$name" >> "$LOG_FILE" 2>&1
}

# Install via curl-based installer with a description
curl_install() {
    local name="$1" url="$2"
    info "Installing ${name} via installer script..."
    log "Curl install: $name from $url"
    bash <(curl -fsSL "$url") >> "$LOG_FILE" 2>&1
}

install_if_missing() {
    local cmd="$1" label="${2:-$1}"
    if cmd_exists "$cmd"; then
        dim "$label already installed — skipping"
        return 0
    fi
    return 1
}

# ── Component Installers ─────────────────────────────────────────────────────

install_core() {
    step "Core — zsh, tmux, git"

    for pkg in zsh tmux git curl wget; do
        if install_if_missing "$pkg" "$pkg"; then continue; fi
        info "Installing $pkg..."
        pkg_install "$pkg" && success "$pkg installed" || error "Failed to install $pkg"
    done

    if [[ "$SHELL" != *"zsh"* ]]; then
        if ask "Set zsh as your default shell?"; then
            chsh -s "$(which zsh)" && success "Default shell set to zsh" || warn "Failed to change shell — run: chsh -s \$(which zsh)"
        fi
    else
        dim "zsh is already your default shell"
    fi
}

install_cli_tools() {
    step "CLI Tools — fzf, fd, eza, bat, dust, btop, neovim"

    if [[ "$PLATFORM" == "arch" ]]; then
        declare -A tools=(
            [fzf]=fzf
            [fd]=fd
            [eza]=eza
            [bat]=bat
            [dust]=dust
            [btop]=btop
            [nvim]=neovim
        )
        for cmd in "${!tools[@]}"; do
            if install_if_missing "$cmd" "${tools[$cmd]}"; then continue; fi
            info "Installing ${tools[$cmd]}..."
            pkg_install "${tools[$cmd]}" && success "${tools[$cmd]} installed" || error "Failed to install ${tools[$cmd]}"
        done

    elif [[ "$PLATFORM" == "debian" ]]; then
        if ! install_if_missing fzf; then
            info "Installing fzf..."
            pkg_install fzf && success "fzf installed" || error "Failed to install fzf"
        fi

        # fd (packaged as fd-find on Debian)
        if ! install_if_missing fdfind fd; then
            info "Installing fd-find..."
            pkg_install fd-find && success "fd-find installed" || error "Failed to install fd-find"
            # Create fd symlink if missing (Debian names binary fdfind)
            if cmd_exists fdfind && ! cmd_exists fd; then
                mkdir -p "$HOME/.local/bin"
                ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
                dim "Created fd → fdfind symlink in ~/.local/bin"
            fi
        fi

        # bat (binary is batcat on older Debian/Ubuntu)
        if ! install_if_missing bat && ! install_if_missing batcat bat; then
            info "Installing bat..."
            pkg_install bat && success "bat installed" || error "Failed to install bat"
            if cmd_exists batcat && ! cmd_exists bat; then
                mkdir -p "$HOME/.local/bin"
                ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
                dim "Created bat → batcat symlink in ~/.local/bin"
            fi
        fi

        if ! install_if_missing eza; then
            info "Installing eza..."
            if ! pkg_install eza 2>/dev/null; then
                warn "eza not in apt repos — installing via cargo..."
                if cmd_exists cargo; then
                    cargo install eza >> "$LOG_FILE" 2>&1 && success "eza installed via cargo" || error "Failed to install eza"
                else
                    warn "cargo not available. Install eza manually: https://github.com/eza-community/eza"
                fi
            else
                success "eza installed"
            fi
        fi

        # dust (packaged as du-dust on some repos)
        if ! install_if_missing dust; then
            info "Installing dust..."
            if ! pkg_install du-dust 2>/dev/null; then
                if cmd_exists cargo; then
                    cargo install du-dust >> "$LOG_FILE" 2>&1 && success "dust installed via cargo" || error "Failed to install dust"
                else
                    warn "dust not in apt repos and cargo not available. Skipping."
                fi
            else
                success "dust installed"
            fi
        fi

        if ! install_if_missing btop; then
            info "Installing btop..."
            pkg_install btop && success "btop installed" || error "Failed to install btop"
        fi

        if ! install_if_missing nvim neovim; then
            info "Installing neovim..."
            pkg_install neovim && success "neovim installed" || error "Failed to install neovim"
        fi
    fi
}

install_shell_enhancements() {
    step "Shell Enhancements — starship, zoxide, atuin, lazygit"

    if [[ "$PLATFORM" == "arch" ]]; then
        detect_aur_helper

        for tool in starship zoxide; do
            if install_if_missing "$tool"; then continue; fi
            info "Installing $tool..."
            pkg_install "$tool" && success "$tool installed" || error "Failed to install $tool"
        done

        # atuin — official repos on newer Arch, AUR fallback
        if ! install_if_missing atuin; then
            info "Installing atuin..."
            if ! pkg_install atuin 2>/dev/null; then
                aur_install atuin && success "atuin installed (AUR)" || warn "atuin: install manually — https://atuin.sh"
            else
                success "atuin installed"
            fi
        fi

        # lazygit — AUR
        if ! install_if_missing lazygit; then
            info "Installing lazygit..."
            aur_install lazygit && success "lazygit installed (AUR)" || warn "lazygit: install manually — https://github.com/jesseduffield/lazygit"
        fi

    elif [[ "$PLATFORM" == "debian" ]]; then
        if ! install_if_missing starship; then
            info "Installing starship..."
            curl -fsSL https://starship.rs/install.sh | sh -s -- -y >> "$LOG_FILE" 2>&1 \
                && success "starship installed" || error "Failed to install starship"
        fi

        if ! install_if_missing zoxide; then
            info "Installing zoxide..."
            if ! pkg_install zoxide 2>/dev/null; then
                curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >> "$LOG_FILE" 2>&1 \
                    && success "zoxide installed" || error "Failed to install zoxide"
            else
                success "zoxide installed"
            fi
        fi

        if ! install_if_missing atuin; then
            info "Installing atuin..."
            curl -fsSL https://setup.atuin.sh | sh >> "$LOG_FILE" 2>&1 \
                && success "atuin installed" || error "Failed to install atuin"
        fi

        if ! install_if_missing lazygit; then
            info "Installing lazygit..."
            local lazygit_version
            lazygit_version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
            if [[ -n "$lazygit_version" ]]; then
                local lazygit_tmp
                lazygit_tmp=$(mktemp -d)
                curl -fsSLo "$lazygit_tmp/lazygit.tar.gz" \
                    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${lazygit_version}_Linux_x86_64.tar.gz"
                tar xzf "$lazygit_tmp/lazygit.tar.gz" -C "$lazygit_tmp"
                install "$lazygit_tmp/lazygit" "$HOME/.local/bin/lazygit"
                rm -rf "$lazygit_tmp"
                success "lazygit ${lazygit_version} installed to ~/.local/bin"
            else
                error "Failed to fetch lazygit version — install manually"
            fi
        fi
    fi
}

install_dev_tools() {
    step "Dev Tools — pyenv, fnm"

    if ! install_if_missing pyenv; then
        info "Installing pyenv..."
        curl -fsSL https://pyenv.run | bash >> "$LOG_FILE" 2>&1 \
            && success "pyenv installed" || error "Failed to install pyenv"
    fi

    if ! install_if_missing fnm; then
        info "Installing fnm..."
        if [[ "$PLATFORM" == "arch" ]]; then
            detect_aur_helper
            if ! pkg_install fnm 2>/dev/null; then
                aur_install fnm && success "fnm installed (AUR)" || {
                    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell >> "$LOG_FILE" 2>&1 \
                        && success "fnm installed" || error "Failed to install fnm"
                }
            else
                success "fnm installed"
            fi
        else
            curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell >> "$LOG_FILE" 2>&1 \
                && success "fnm installed" || error "Failed to install fnm"
        fi
    fi
}

install_fonts() {
    step "Fonts — JetBrains Mono Nerd Font"

    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNF"

    if [[ -d "$font_dir" ]] && ls "$font_dir"/*.ttf &>/dev/null; then
        dim "JetBrains Mono Nerd Font already installed — skipping"
        return
    fi

    info "Downloading JetBrains Mono Nerd Font..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local nf_version="v3.3.0"
    curl -fsSLo "$tmp_dir/JetBrainsMono.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/${nf_version}/JetBrainsMono.tar.xz" \
        || { error "Failed to download font"; return; }

    mkdir -p "$font_dir"
    tar xf "$tmp_dir/JetBrainsMono.tar.xz" -C "$font_dir"
    rm -rf "$tmp_dir"

    if cmd_exists fc-cache; then
        fc-cache -fv "$font_dir" >> "$LOG_FILE" 2>&1
    fi
    success "JetBrains Mono Nerd Font installed to $font_dir"
}

# ── Symlink Manager ──────────────────────────────────────────────────────────
backup_file() {
    local target="$1"
    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$target" "$BACKUP_DIR/"
        dim "Backed up $(basename "$target") → $BACKUP_DIR/"
        log "Backup: $target → $BACKUP_DIR/$(basename "$target")"
    fi
}

create_symlink() {
    local src="$1" dest="$2" label="$3"

    if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
        dim "$label already symlinked — skipping"
        return
    fi

    backup_file "$dest"
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
    success "$label → $dest"
    log "Symlink: $src → $dest"
}

setup_symlinks() {
    step "Symlinks — linking configs"

    create_symlink "$REPO_DIR/zshrc"          "$HOME/.zshrc"                     "zshrc"
    create_symlink "$REPO_DIR/zsh_aliases"    "$HOME/.zsh_aliases"               "zsh_aliases"
    create_symlink "$REPO_DIR/zsh_functions"  "$HOME/.zsh_functions"             "zsh_functions"
    create_symlink "$REPO_DIR/tmux.conf"      "$HOME/.tmux.conf"                 "tmux.conf"
    create_symlink "$REPO_DIR/ghostty_config" "$HOME/.config/ghostty/config"     "ghostty_config"

    echo ""
    info "Existing config files were backed up to:"
    dim "$BACKUP_DIR"
}

# ── Post-Install Setup ───────────────────────────────────────────────────────
post_install() {
    step "Post-Install Setup"

    # TPM (tmux plugin manager)
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        info "Installing tmux plugin manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir" >> "$LOG_FILE" 2>&1 \
            && success "TPM installed — press \`I inside tmux to install plugins" \
            || error "Failed to clone TPM"
    else
        dim "TPM already installed — skipping"
    fi

    # Zinit (auto-bootstrapped by zshrc, just verify)
    local zinit_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
    if [[ -d "$zinit_dir" ]]; then
        dim "Zinit already installed (will self-update)"
    else
        dim "Zinit will auto-install on first zsh launch"
    fi

    # Create ~/.zfunc directory (referenced in zshrc)
    mkdir -p "$HOME/.zfunc"
}

# ── Banner ────────────────────────────────────────────────────────────────────
show_banner() {
    echo -e "${MAGENTA}${BOLD}"
    cat << 'BANNER'
                          ╭─────────────────────────────╮
  ███╗   ██╗███████╗██╗   ██╗██████╗  █████╗ ██╗       │  zsh + tmux + ghostty   │
  ████╗  ██║██╔════╝██║   ██║██╔══██╗██╔══██╗██║       │  interactive installer  │
  ██╔██╗ ██║█████╗  ██║   ██║██████╔╝███████║██║       ╰─────────────────────────╯
  ██║╚██╗██║██╔══╝  ██║   ██║██╔══██╗██╔══██║██║
  ██║ ╚████║███████╗╚██████╔╝██║  ██║██║  ██║███████╗
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝  LINK
BANNER
    echo -e "${NC}"
}

show_summary() {
    echo ""
    echo -e "${CYAN}${BOLD}Components:${NC}"
    echo ""
    echo -e "  ${BOLD}[1]${NC} Core              zsh, tmux, git, curl, wget"
    echo -e "  ${BOLD}[2]${NC} CLI Tools         fzf, fd, eza, bat, dust, btop, neovim"
    echo -e "  ${BOLD}[3]${NC} Shell Enhancers   starship, zoxide, atuin, lazygit"
    echo -e "  ${BOLD}[4]${NC} Dev Tools         pyenv, fnm"
    echo -e "  ${BOLD}[5]${NC} Fonts             JetBrains Mono Nerd Font"
    echo -e "  ${BOLD}[6]${NC} Symlink Configs   zshrc, tmux.conf, ghostty, aliases, functions"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    show_banner

    detect_platform
    success "Detected platform: ${BOLD}${PLATFORM}${NC} (${PKG_MGR})"
    if [[ "$PLATFORM" == "arch" ]]; then
        detect_aur_helper
        if [[ -n "$aur_helper" ]]; then
            dim "AUR helper: $aur_helper"
        else
            warn "No AUR helper detected (paru/yay) — some packages may need manual install"
        fi
    fi

    show_summary

    local do_core do_cli do_shell do_dev do_fonts do_symlinks

    do_core=$(ask "Install Core (zsh, tmux, git)?" y && echo y || echo n)
    do_cli=$(ask "Install CLI Tools (fzf, fd, eza, bat, dust, btop, neovim)?" y && echo y || echo n)
    do_shell=$(ask "Install Shell Enhancements (starship, zoxide, atuin, lazygit)?" y && echo y || echo n)
    do_dev=$(ask "Install Dev Tools (pyenv, fnm)?" n && echo y || echo n)
    do_fonts=$(ask "Install JetBrains Mono Nerd Font?" y && echo y || echo n)
    do_symlinks=$(ask "Create config symlinks?" y && echo y || echo n)

    echo ""

    echo -e "${BOLD}Ready to install:${NC}"
    [[ "$do_core"     == "y" ]] && echo -e "  ${GREEN}✓${NC} Core"
    [[ "$do_cli"      == "y" ]] && echo -e "  ${GREEN}✓${NC} CLI Tools"
    [[ "$do_shell"    == "y" ]] && echo -e "  ${GREEN}✓${NC} Shell Enhancements"
    [[ "$do_dev"      == "y" ]] && echo -e "  ${GREEN}✓${NC} Dev Tools"
    [[ "$do_fonts"    == "y" ]] && echo -e "  ${GREEN}✓${NC} Fonts"
    [[ "$do_symlinks" == "y" ]] && echo -e "  ${GREEN}✓${NC} Symlink Configs"
    [[ "$do_core$do_cli$do_shell$do_dev$do_fonts$do_symlinks" == "nnnnnn" ]] && {
        warn "Nothing selected. Exiting."
        exit 0
    }
    echo ""

    if ! ask "Proceed with installation?" y; then
        warn "Aborted."
        exit 0
    fi

    if [[ "$do_core$do_cli$do_shell$do_dev" == *"y"* ]]; then
        step "Updating package index"
        case "$PKG_MGR" in
            pacman) sudo pacman -Sy >> "$LOG_FILE" 2>&1 && success "Package index updated" ;;
            apt)    sudo apt-get update >> "$LOG_FILE" 2>&1 && success "Package index updated" ;;
        esac
    fi

    [[ "$do_core"     == "y" ]] && install_core
    [[ "$do_cli"      == "y" ]] && install_cli_tools
    [[ "$do_shell"    == "y" ]] && install_shell_enhancements
    [[ "$do_dev"      == "y" ]] && install_dev_tools
    [[ "$do_fonts"    == "y" ]] && install_fonts
    [[ "$do_symlinks" == "y" ]] && { setup_symlinks; post_install; }

    step "Done"
    success "neuralink installation complete!"
    echo ""
    info "Log file: ${DIM}$LOG_FILE${NC}"
    if [[ "$do_symlinks" == "y" ]]; then
        echo ""
        info "Config symlinks are live — edit files in:"
        dim "$REPO_DIR"
        info "Changes apply immediately (no re-install needed)."
        echo ""
        info "Next steps:"
        dim "1. Restart your terminal (or run: exec zsh)"
        dim "2. Open tmux and press \`I to install tmux plugins"
        dim "3. Enjoy your new setup ⚡"
    fi
    echo ""
}

main "$@"
