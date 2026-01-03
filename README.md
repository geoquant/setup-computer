# setup-computer

Mac setup automation and dotfiles for a fresh machine.

## Quick Start

```bash
# Clone this repo
git clone git@github.com:geoquant/setup-computer.git ~/setup-computer

# Run the setup script
chmod +x ~/setup-computer/mac-setup.sh
~/setup-computer/mac-setup.sh
```

## What's Included

### mac-setup.sh
Automated setup script that installs:
- Xcode CLI tools
- Homebrew + packages (git, gh, nvm, pnpm, bun, fzf, zoxide, eza, bat, lazygit, btop, yazi, neovim, etc.)
- Ghostty terminal
- SSH key generation (auto-copies to clipboard for GitHub)
- Git global config
- Oh My Zsh + Starship prompt
- Node.js via NVM
- Kickstart.nvim
- Claude Code + OpenCode
- Dotfiles bare repo

### dotfiles/
- `.zshrc` - Zsh config with NVM, zoxide, starship, dotfiles alias
- `.gitconfig` - Git global settings
- `.config/nvim/` - Kickstart.nvim with custom keymaps

## Dotfiles Strategy

Uses a git bare repo approach:
```bash
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Track a file
dotfiles add ~/.zshrc
dotfiles commit -m "Update zshrc"
dotfiles push
```

## Manual Steps

After running the script:
1. Download [Handy](https://handy.computer/download) (local speech-to-text)
2. Restart terminal to load configs
3. Run `gh auth login` if not already authenticated
