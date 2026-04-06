#!/usr/bin/env bash
# =============================================================================
# macOS Developer Setup Script
# Run: bash setup.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log()     { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
section() { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}"; }
ok()      { echo -e "${GREEN}[✓]${NC} $1"; }

# =============================================================================
# XCODE COMMAND LINE TOOLS
# =============================================================================
section "Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
  ok "Already installed"
else
  log "Installing Xcode CLT..."
  xcode-select --install
  until xcode-select -p &>/dev/null; do sleep 5; done
  ok "Installed"
fi

# =============================================================================
# HOMEBREW
# =============================================================================
section "Homebrew"
if command -v brew &>/dev/null; then
  ok "Already installed — updating..."
  brew update --quiet
else
  log "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -m) == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Installed"
fi

# =============================================================================
# CLI TOOLS
# =============================================================================
section "CLI Tools"

CLI_TOOLS=(
  bat        # cat with syntax highlighting
  blueutil   # bluetooth CLI
  btop       # resource monitor
  cmatrix    # matrix rain
  cowsay
  fd         # fast find
  gh         # GitHub CLI
  htop
  lazygit    # TUI git client
  lolcat     # rainbow output
  neovim
  nmap
  nvm        # node version manager
  ranger     # terminal file manager
  ripgrep    # fast grep (rg)
  tmux
)

for tool in "${CLI_TOOLS[@]}"; do
  if brew list "$tool" &>/dev/null 2>&1; then
    ok "$tool already installed"
  else
    log "Installing $tool..."
    brew install "$tool" || warn "Failed to install $tool — skipping"
  fi
done

# =============================================================================
# GUI APPS (Homebrew Cask)
# Note: Firefox, VS Code, VLC, Ghostty, Claude, ChatGPT, AlDente, Tailscale,
#       Wispr Flow, superwhisper, Transmission, CotEditor — install manually
# =============================================================================
section "GUI Applications"

GUI_APPS=(
  # Productivity / utilities
  raycast
  aldente
  tailscale
  coteditor

  # Terminals / editors
  ghostty
  visual-studio-code
  codex

  # Browsers
  firefox

  # AI
  claude
  chatgpt
  superwhisper
  wispr-flow

  # Media
  vlc
  transmission

  # Fonts
  font-jetbrains-mono-nerd-font
  font-noto-sans-mono-cjk-jp
)

for app in "${GUI_APPS[@]}"; do
  if brew list --cask "$app" &>/dev/null 2>&1; then
    ok "$app already installed"
  else
    log "Installing $app..."
    brew install --cask "$app" || warn "Failed to install $app — skipping"
  fi
done

# =============================================================================
# OH MY ZSH
# =============================================================================
section "Oh My Zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "Already installed"
else
  log "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "Installed"
fi

# =============================================================================
# NODE (via nvm)
# =============================================================================
section "Node (via nvm)"
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

if command -v nvm &>/dev/null; then
  if nvm ls --no-colors | grep -q "v24"; then
    ok "Node v24 already installed"
  else
    log "Installing Node v24 (LTS)..."
    nvm install 24
    nvm alias default 24
    ok "Node $(node -v) installed"
  fi
else
  warn "nvm not loaded — run 'source ~/.zshrc' and re-run this script to install Node"
fi

# =============================================================================
# GLOBAL NPM PACKAGES
# =============================================================================
section "Global NPM Packages"

NPM_GLOBALS=(
  @google/gemini-cli
)

for pkg in "${NPM_GLOBALS[@]}"; do
  if npm list -g "$pkg" --depth=0 &>/dev/null 2>&1; then
    ok "$pkg already installed"
  else
    log "Installing $pkg..."
    npm install -g "$pkg" --silent || warn "Failed to install $pkg"
  fi
done

# =============================================================================
# WRITE .zshrc
# =============================================================================
section "Writing ~/.zshrc"

ZSHRC="$HOME/.zshrc"
if grep -q "# <<< mac-setup >>>" "$ZSHRC" 2>/dev/null; then
  ok ".zshrc already configured"
else
  log "Writing .zshrc..."
  cat > "$ZSHRC" << 'EOF'
# <<< mac-setup >>>

export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Homebrew (Apple Silicon)
[[ $(uname -m) == "arm64" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias cc="claude --dangerously-skip-permissions"
alias vim="nvim"
alias lg="lazygit"

# Default directory
cd ~/Developer
EOF
  ok ".zshrc written"
fi

# =============================================================================
# MACOS DEFAULTS
# =============================================================================
section "macOS System Preferences"

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Trackpad
defaults write com.apple.trackpad scaling -float 1.5
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location "$HOME/Screenshots"

killall Dock Finder 2>/dev/null || true
ok "macOS defaults applied"

# =============================================================================
# DONE
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}=====================================${NC}"
echo -e "${BOLD}${GREEN}  Setup complete!${NC}"
echo -e "${BOLD}${GREEN}=====================================${NC}"
echo ""
echo -e "After install: ${YELLOW}source ~/.zshrc${NC}"
echo ""
