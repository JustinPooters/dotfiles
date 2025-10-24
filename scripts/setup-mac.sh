#!/usr/bin/env bash
set -euo pipefail
cyan='\033[0;36m'; green='\033[0;32m'; yellow='\033[1;33m'; red='\033[0;31m'; nc='\033[0m'
step(){ echo -e "\n${cyan}=== $* ===${nc}"; }
ok(){ echo -e "${green}✔ $*${nc}"; }
warn(){ echo -e "${yellow}⚠ $*${nc}"; }
err(){ echo -e "${red}✖ $*${nc}"; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link_or_copy() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  [ -e "$dst" ] && rm -rf "$dst"
  if ln -s "$src" "$dst" 2>/dev/null; then
    ok "Linked: $dst → $src"
  else
    cp -r "$src" "$dst"
    warn "Symlink failed; copied instead: $dst"
  fi
}

# -------- Homebrew --------
if ! command -v brew >/dev/null 2>&1; then
  step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew update

# -------- Install tools --------
step "Installing core tools (git, starship, jq, wget)"
brew install git starship jq wget || true
ok "Core tools installed"

# -------- Starship theme --------
step "Configuring Starship prompt"
STAR_CFG_SRC="$REPO/terminal/starship.toml"
STAR_CFG_DST="$HOME/.config/starship.toml"
mkdir -p "$(dirname "$STAR_CFG_DST")"
link_or_copy "$STAR_CFG_SRC" "$STAR_CFG_DST"

CFG_DIR="$HOME/.config/dev-configs"
mkdir -p "$CFG_DIR"
link_or_copy "$REPO/terminal/dotnet-version.sh" "$CFG_DIR/dotnet-version.sh"

ZSHRC="$HOME/.zshrc"
grep -q 'source ~/.config/dev-configs/dotnet-version.sh' "$ZSHRC" 2>/dev/null ||   echo 'source ~/.config/dev-configs/dotnet-version.sh' >> "$ZSHRC"
grep -q 'eval "$(starship init zsh)"' "$ZSHRC" 2>/dev/null ||   echo 'eval "$(starship init zsh)"' >> "$ZSHRC"
ok "Starship configured"

# -------- VS Code --------
if command -v code >/dev/null 2>&1; then
  step "Applying VS Code settings"
  VSUSER="$HOME/Library/Application Support/Code/User"
  mkdir -p "$VSUSER"
  [[ -f "$REPO/vscode/settings.json"    ]] && link_or_copy "$REPO/vscode/settings.json"    "$VSUSER/settings.json"
  [[ -f "$REPO/vscode/keybindings.json" ]] && link_or_copy "$REPO/vscode/keybindings.json" "$VSUSER/keybindings.json"
  [[ -f "$REPO/vscode/extensions.txt"   ]] && xargs -L1 code --install-extension < "$REPO/vscode/extensions.txt" || true
  ok "VS Code configured"
else
  warn "VS Code CLI not found; skipping"
fi

# -------- Git --------
step "Linking Git config"
[[ -f "$REPO/git/.gitconfig"        ]] && link_or_copy "$REPO/git/.gitconfig"        "$HOME/.gitconfig"
[[ -f "$REPO/git/.gitignore_global" ]] && link_or_copy "$REPO/git/.gitignore_global" "$HOME/.gitignore_global"

ok "Done. Restart your terminal or run 'exec zsh' to load the theme."
