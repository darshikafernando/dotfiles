# =============================================================================
# Zsh Configuration (for devcontainer use)
# =============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	autojump
)

source $ZSH/oh-my-zsh.sh

# =============================================================================
# Devcontainer Requirements
# =============================================================================

# direnv hook (required for ai-services environment variables)
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# Persistent shell history (survives container rebuilds)
# Uses Docker volume mounted at ~/.shell_history/
if [[ -d "$HOME/.shell_history" ]]; then
    HISTFILE="$HOME/.shell_history/.zsh_history"
else
    HISTFILE="$HOME/.zsh_history"
fi
HISTSIZE=10000
SAVEHIST=10000

# =============================================================================
# User Configuration
# =============================================================================

# Path
export PATH="$HOME/.local/bin:$PATH"

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Pants shortcuts (for ai-services)
alias pt='pants test'
alias pf='pants fmt'
alias pl='pants lint'
alias pc='pants check'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
