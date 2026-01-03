# Mac Setup

Instructions for setting up a new Mac laptop.

> Note: If a tool is already installed, the script will warn and attempt to upgrade to latest.

> **Automation Limitation**: Several steps require password input (Homebrew install, casks with `sudo`, xcode-select) or GUI interaction (security tools need System Settings permissions). Script will be semi-automated — runs what it can, pauses for user input when needed.

## 1. Prerequisites

```bash
# Xcode Command Line Tools (required for git, compilers, etc.)
xcode-select --install
```

## 2. Homebrew (install first - used for most tools)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 3. Tools via Homebrew

```bash
# Git (also included in Xcode CLI tools, but brew version is more up-to-date)
brew install git

# GitHub CLI
brew install gh

# Node Version Manager
brew install nvm

# Package managers
brew install pnpm
brew install bun
brew install ni

# Terminal utilities
brew install fzf
brew install zoxide
brew install eza
brew install bat
brew install lazygit
brew install btop

# File manager (with optional deps for previews)
brew install yazi ffmpegthumbnailer sevenzip jq poppler fd ripgrep fzf zoxide imagemagick font-symbols-only-nerd-font

# Editor
brew install neovim

# Languages
brew install r
```

### Casks (GUI apps)

```bash
brew install --cask ghostty
```

### Manual downloads

- **Handy** (local speech-to-text) — https://handy.computer/download

### nvm post-install

```bash
# Add to ~/.zshrc
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

# Install latest Node.js (includes npm)
nvm install node
```

### zoxide post-install

```bash
# Add to ~/.zshrc
eval "$(zoxide init zsh)"
```

## 4. Git/GitHub Setup

### SSH key

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Start ssh-agent and add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard, then add to GitHub Settings > SSH Keys
pbcopy < ~/.ssh/id_ed25519.pub
```

### Git global config

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
git config --global init.defaultBranch main
git config --global core.editor "nvim"
```

### GPG signing (optional)

```bash
brew install gnupg

# Generate GPG key
gpg --full-generate-key

# Get key ID and configure git
gpg --list-secret-keys --keyid-format=long
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# Export public key for GitHub
gpg --armor --export YOUR_KEY_ID | pbcopy
```

## 5. Shell

### Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Starship (fast Rust-based prompt, cross-shell, minimal config)

```bash
brew install starship
```

```bash
# Add to end of ~/.zshrc
eval "$(starship init zsh)"
```

## 6. Neovim Config

### Kickstart.nvim

```bash
# Backup existing config if present
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.bak

# Clone kickstart
git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim
```

### Custom keymaps (add to ~/.config/nvim/init.lua)

```lua
-- Move lines up/down in visual mode
vim.keymap.set("v", "<M-Up>", ":m '<-2<CR>gv=gv", { desc = "Move lines up" })
vim.keymap.set("v", "<M-Down>", ":m '>+1<CR>gv=gv", { desc = "Move lines down" })

-- Move line in normal mode
vim.keymap.set("n", "<M-Up>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("n", "<M-Down>", ":m .+1<CR>==", { desc = "Move line down" })

-- Move line in insert mode
vim.keymap.set("i", "<M-Up>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up" })
vim.keymap.set("i", "<M-Down>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down" })
```

## 7. AI Tools

### Claude Code

```bash
# Requires Node.js/npm
npm install -g @anthropic-ai/claude-code
```

### OpenCode

```bash
curl -fsSL https://opencode.ai/install | bash
```

## 8. Dotfiles

Strategy for backing up and syncing config files across machines.

### Option A: Git bare repo

```bash
# Initialize
git init --bare $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no

# Add alias to ~/.zshrc
echo "alias dotfiles='git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.zshrc

# Usage
dotfiles add ~/.zshrc
dotfiles commit -m "Add zshrc"
dotfiles push
```

### Option B: Symlink with a dotfiles repo

```bash
# Clone your dotfiles repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Symlink configs
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
# ... add more as needed
```

### Key files to track

- `~/.zshrc`
- `~/.config/nvim/`
- `~/.config/starship.toml`
- `~/.config/ghostty/`
- `~/.gitconfig`
