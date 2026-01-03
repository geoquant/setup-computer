#!/bin/bash

# Mac Setup Script for Jonnie Lappen
# Semi-automated - will pause for user input when needed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# User config
GIT_NAME="Jonnie Lappen"
GIT_EMAIL="jonnie.lappen@gmail.com"
GITHUB_USER="geoquant"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
pause() { echo -e "${YELLOW}Press Enter to continue...${NC}"; read -r; }

# ============================================================================
# 1. XCODE COMMAND LINE TOOLS
# ============================================================================
install_xcode_cli() {
    log_info "Checking Xcode Command Line Tools..."
    if xcode-select -p &>/dev/null; then
        log_success "Xcode CLI tools already installed"
    else
        log_warn "Installing Xcode CLI tools - a dialog will appear"
        xcode-select --install
        log_warn "Wait for installation to complete, then press Enter"
        pause
    fi
}

# ============================================================================
# 2. HOMEBREW
# ============================================================================
install_homebrew() {
    log_info "Checking Homebrew..."
    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed"
        log_info "Updating Homebrew..."
        brew update
    else
        log_warn "Installing Homebrew - you'll need to enter your password"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add to path for this session
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

# ============================================================================
# 3. HOMEBREW PACKAGES
# ============================================================================
install_brew_packages() {
    log_info "Installing Homebrew packages..."

    BREW_PACKAGES=(
        git
        gh
        nvm
        pnpm
        ni
        fzf
        zoxide
        eza
        bat
        lazygit
        btop
        yazi
        ffmpegthumbnailer
        sevenzip
        jq
        poppler
        fd
        ripgrep
        imagemagick
        neovim
        r
        starship
    )

    for pkg in "${BREW_PACKAGES[@]}"; do
        if brew list "$pkg" &>/dev/null; then
            log_success "$pkg already installed"
        else
            log_info "Installing $pkg..."
            brew install "$pkg" || log_warn "Failed to install $pkg"
        fi
    done

    # Font (separate because it's a cask-like formula)
    if brew list font-symbols-only-nerd-font &>/dev/null; then
        log_success "font-symbols-only-nerd-font already installed"
    else
        log_info "Installing font-symbols-only-nerd-font..."
        brew install font-symbols-only-nerd-font || log_warn "Failed to install font"
    fi
}

# ============================================================================
# 4. HOMEBREW CASKS
# ============================================================================
install_brew_casks() {
    log_info "Installing Homebrew casks..."

    CASKS=(ghostty)

    for cask in "${CASKS[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            log_success "$cask already installed"
        else
            log_info "Installing $cask..."
            brew install --cask "$cask" || log_warn "Failed to install $cask"
        fi
    done
}

# ============================================================================
# 5. SSH KEY SETUP
# ============================================================================
setup_ssh() {
    log_info "Setting up SSH key..."

    if [[ -f ~/.ssh/id_ed25519 ]]; then
        log_success "SSH key already exists"
    else
        log_info "Generating new SSH key..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f ~/.ssh/id_ed25519 -N ""
        log_success "SSH key generated"
    fi

    # Start ssh-agent and add key
    eval "$(ssh-agent -s)" &>/dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null || true

    # Copy to clipboard
    pbcopy < ~/.ssh/id_ed25519.pub
    log_success "Public key copied to clipboard"
    log_warn "Add this key to GitHub: Settings > SSH and GPG Keys > New SSH Key"
    log_info "Opening GitHub SSH settings..."
    open "https://github.com/settings/ssh/new"
    pause
}

# ============================================================================
# 6. GIT CONFIG
# ============================================================================
setup_git() {
    log_info "Configuring Git..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global init.defaultBranch main
    git config --global core.editor "nvim"
    log_success "Git configured"
}

# ============================================================================
# 7. OH MY ZSH
# ============================================================================
install_oh_my_zsh() {
    log_info "Checking Oh My Zsh..."
    if [[ -d ~/.oh-my-zsh ]]; then
        log_success "Oh My Zsh already installed"
    else
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    fi
}

# ============================================================================
# 8. ZSHRC CONFIGURATION
# ============================================================================
configure_zshrc() {
    log_info "Configuring ~/.zshrc..."

    ZSHRC="$HOME/.zshrc"

    # Backup existing
    if [[ -f "$ZSHRC" ]]; then
        cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d%H%M%S)"
    fi

    # PATH configuration (Homebrew, local bins, opencode)
    if ! grep -q 'brew shellenv' "$ZSHRC" 2>/dev/null; then
        # Insert at the top of the file after any initial comments
        TEMP_FILE=$(mktemp)
        cat > "$TEMP_FILE" << 'EOF'
# PATH configuration
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

EOF
        cat "$ZSHRC" >> "$TEMP_FILE"
        mv "$TEMP_FILE" "$ZSHRC"
        log_success "Added PATH config to .zshrc"
    fi

    # NVM config
    if ! grep -q 'NVM_DIR' "$ZSHRC" 2>/dev/null; then
        cat >> "$ZSHRC" << 'EOF'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
EOF
        log_success "Added NVM config to .zshrc"
    fi

    # Zoxide
    if ! grep -q 'zoxide init' "$ZSHRC" 2>/dev/null; then
        echo '' >> "$ZSHRC"
        echo '# Zoxide' >> "$ZSHRC"
        echo 'eval "$(zoxide init zsh)"' >> "$ZSHRC"
        log_success "Added zoxide config to .zshrc"
    fi

    # Starship
    if ! grep -q 'starship init' "$ZSHRC" 2>/dev/null; then
        echo '' >> "$ZSHRC"
        echo '# Starship prompt' >> "$ZSHRC"
        echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
        log_success "Added starship config to .zshrc"
    fi

    # Dotfiles alias for bare repo
    if ! grep -q "alias dotfiles=" "$ZSHRC" 2>/dev/null; then
        echo '' >> "$ZSHRC"
        echo '# Dotfiles bare repo alias' >> "$ZSHRC"
        echo "alias dotfiles='git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> "$ZSHRC"
        log_success "Added dotfiles alias to .zshrc"
    fi
}

# ============================================================================
# 9. NODE.JS VIA NVM
# ============================================================================
install_node() {
    log_info "Installing Node.js via NVM..."

    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

    if command -v nvm &>/dev/null; then
        nvm install node
        log_success "Node.js installed: $(node --version)"
    else
        log_warn "NVM not available in this session - run 'nvm install node' after restarting shell"
    fi
}

# ============================================================================
# 10. NEOVIM CONFIG (KICKSTART)
# ============================================================================
setup_neovim() {
    log_info "Setting up Neovim with Kickstart..."

    NVIM_CONFIG="$HOME/.config/nvim"

    if [[ -d "$NVIM_CONFIG" ]]; then
        if [[ -d "$NVIM_CONFIG/.git" ]]; then
            log_success "Neovim config already exists (git repo)"
        else
            mv "$NVIM_CONFIG" "$NVIM_CONFIG.bak.$(date +%Y%m%d%H%M%S)"
            log_info "Backed up existing config"
            git clone https://github.com/nvim-lua/kickstart.nvim.git "$NVIM_CONFIG"
            log_success "Kickstart.nvim installed"
        fi
    else
        mkdir -p "$HOME/.config"
        git clone https://github.com/nvim-lua/kickstart.nvim.git "$NVIM_CONFIG"
        log_success "Kickstart.nvim installed"
    fi

    # Add custom keymaps
    INIT_LUA="$NVIM_CONFIG/init.lua"
    if [[ -f "$INIT_LUA" ]] && ! grep -q "Move lines up/down" "$INIT_LUA"; then
        cat >> "$INIT_LUA" << 'EOF'

-- Custom keymaps: Move lines up/down
vim.keymap.set("v", "<M-Up>", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })
vim.keymap.set("v", "<M-Down>", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })
vim.keymap.set("n", "<M-Up>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<M-Down>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("i", "<M-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("i", "<M-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
EOF
        log_success "Added custom keymaps to init.lua"
    fi
}

# ============================================================================
# 11. BUN
# ============================================================================
install_bun() {
    log_info "Installing Bun..."

    if [[ -f "$HOME/.bun/bin/bun" ]]; then
        log_success "Bun already installed"
    else
        curl -fsSL https://bun.sh/install | bash
        log_success "Bun installed"
    fi
}

# ============================================================================
# 12. AI TOOLS
# ============================================================================
install_ai_tools() {
    log_info "Installing AI tools..."

    # Claude Code
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

    if command -v npm &>/dev/null; then
        if npm list -g @anthropic-ai/claude-code &>/dev/null; then
            log_success "Claude Code already installed"
        else
            log_info "Installing Claude Code..."
            npm install -g @anthropic-ai/claude-code
            log_success "Claude Code installed"
        fi
    else
        log_warn "npm not available - install Claude Code after restarting shell"
    fi

    # OpenCode
    if [[ -f "$HOME/.opencode/bin/opencode" ]]; then
        log_success "OpenCode already installed"
    else
        log_info "Installing OpenCode..."
        curl -fsSL https://opencode.ai/install | bash || log_warn "OpenCode installation failed"
    fi
}

# ============================================================================
# 13. DOTFILES BARE REPO
# ============================================================================
setup_dotfiles_repo() {
    log_info "Setting up dotfiles bare repo..."

    if [[ -d "$HOME/.dotfiles" ]]; then
        log_success "Dotfiles repo already exists"
    else
        git init --bare "$HOME/.dotfiles"
        # Configure to not show untracked files
        git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" config --local status.showUntrackedFiles no
        log_success "Dotfiles bare repo initialized"
    fi
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       Mac Setup Script - Jonnie Lappen     ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""

    install_xcode_cli
    install_homebrew
    install_brew_packages
    install_brew_casks
    setup_ssh
    setup_git
    install_oh_my_zsh
    configure_zshrc
    install_node
    install_bun
    setup_neovim
    install_ai_tools
    setup_dotfiles_repo

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║            Setup Complete!                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"
    echo ""
    log_info "Manual steps remaining:"
    echo "  1. Download Handy: https://handy.computer/download"
    echo "  2. Restart your terminal to load all configs"
    echo "  3. Run 'gh auth login' to authenticate GitHub CLI"
    echo ""
}

main "$@"
