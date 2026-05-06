#!/bin/bash
# =============================================================================
# Dotfiles Installation Script
# =============================================================================
# Installs zsh with Oh My Zsh, Powerlevel10k, and plugins.
# Designed for use with devcontainers.
# =============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# -----------------------------------------------------------------------------
# Install zsh
# -----------------------------------------------------------------------------
install_zsh() {
    if command -v zsh &>/dev/null; then
        echo "  zsh already installed"
    else
        echo "  Installing zsh..."
        sudo apt-get update -qq
        sudo apt-get install -y zsh
    fi
}

# -----------------------------------------------------------------------------
# Install Oh My Zsh
# -----------------------------------------------------------------------------
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "  Oh My Zsh already installed"
    else
        echo "  Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# -----------------------------------------------------------------------------
# Install Powerlevel10k theme
# -----------------------------------------------------------------------------
install_powerlevel10k() {
    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [[ -d "$p10k_dir" ]]; then
        echo "  Powerlevel10k already installed"
    else
        echo "  Installing Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    fi
}

# -----------------------------------------------------------------------------
# Install zsh plugins
# -----------------------------------------------------------------------------
install_plugins() {
    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

    # zsh-autosuggestions
    if [[ -d "$custom_dir/zsh-autosuggestions" ]]; then
        echo "  zsh-autosuggestions already installed"
    else
        echo "  Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [[ -d "$custom_dir/zsh-syntax-highlighting" ]]; then
        echo "  zsh-syntax-highlighting already installed"
    else
        echo "  Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom_dir/zsh-syntax-highlighting"
    fi

    # autojump (apt package)
    if command -v autojump &>/dev/null; then
        echo "  autojump already installed"
    else
        echo "  Installing autojump..."
        sudo apt-get install -y autojump 2>/dev/null || echo "  autojump not available via apt"
    fi
}

# -----------------------------------------------------------------------------
# Link dotfiles
# -----------------------------------------------------------------------------
link_dotfiles() {
    echo "  Linking dotfiles..."

    # Backup existing files
    [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]] && mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
    [[ -f "$HOME/.p10k.zsh" && ! -L "$HOME/.p10k.zsh" ]] && mv "$HOME/.p10k.zsh" "$HOME/.p10k.zsh.backup"

    # Create symlinks
    ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

    echo "  Linked .zshrc and .p10k.zsh"
}

# -----------------------------------------------------------------------------
# Link Claude Code assets (CLAUDE.md, settings.json, skills/)
# -----------------------------------------------------------------------------
# ~/.claude/ holds session state we must not touch — only link the assets
# we manage in dotfiles. Existing files are backed up to *.backup once.
link_claude_assets() {
    local src_dir="$DOTFILES_DIR/.claude"
    local dst_dir="$HOME/.claude"

    [[ -d "$src_dir" ]] || { echo "  No .claude in dotfiles, skipping"; return; }

    mkdir -p "$dst_dir"
    echo "  Linking Claude Code assets..."

    # CLAUDE.md
    if [[ -f "$dst_dir/CLAUDE.md" && ! -L "$dst_dir/CLAUDE.md" ]]; then
        mv "$dst_dir/CLAUDE.md" "$dst_dir/CLAUDE.md.backup"
    fi
    ln -sf "$src_dir/CLAUDE.md" "$dst_dir/CLAUDE.md"

    # settings.json
    if [[ -f "$dst_dir/settings.json" && ! -L "$dst_dir/settings.json" ]]; then
        mv "$dst_dir/settings.json" "$dst_dir/settings.json.backup"
    fi
    ln -sf "$src_dir/settings.json" "$dst_dir/settings.json"

    # skills/ — link the parent dir so new skills appear without re-running
    if [[ -d "$dst_dir/skills" && ! -L "$dst_dir/skills" ]]; then
        mv "$dst_dir/skills" "$dst_dir/skills.backup"
    fi
    ln -sfn "$src_dir/skills" "$dst_dir/skills"

    echo "  Linked CLAUDE.md, settings.json, skills/"
}

# -----------------------------------------------------------------------------
# Set zsh as default shell
# -----------------------------------------------------------------------------
set_default_shell() {
    if [[ "$SHELL" == */zsh ]]; then
        echo "  zsh is already default shell"
    else
        echo "  Setting zsh as default shell..."
        sudo chsh -s "$(which zsh)" "$(whoami)" 2>/dev/null || echo "  Could not change default shell (may need manual intervention)"
    fi
}

# -----------------------------------------------------------------------------
# Configure for devcontainer
# -----------------------------------------------------------------------------
configure_devcontainer() {
    # Trust ai-services .envrc if it exists
    if [[ -f "/workspaces/ai-services/.envrc" ]]; then
        echo "  Trusting ai-services .envrc..."
        direnv allow /workspaces/ai-services 2>/dev/null || true
    fi
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo "=== Dotfiles Installation ==="
    echo ""

    install_zsh
    install_oh_my_zsh
    install_powerlevel10k
    install_plugins
    link_dotfiles
    link_claude_assets
    set_default_shell
    configure_devcontainer

    echo ""
    echo "=== Installation Complete ==="
    echo ""
    echo "Open a new terminal to use zsh with your configuration."
    echo ""
}

main "$@"
