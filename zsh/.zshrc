# Source the zinit framework
source "${ZDOTDIR:-$HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# Load plugins
zinit wait lucid light-mode for \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    junegunn/fzf

export EDITOR=nvim
# Your custom aliases
alias pamcan='pacman'
alias ls='eza --icons'
alias q='qs -c ii'
alias lg='lazygit'

# Zsh-specific options and configurations
# Disable some globbing options to prevent errors with certain commands
setopt no_glob_subst
setopt interactive_comments
setopt prompt_subst
setopt extendedglob

# The following lines are not strictly necessary for functionality, but they
# can make the shell behave more predictably if you are used to a certain
# behavior.
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Starship prompt configuration
# This is the Zsh equivalent of `starship init fish`
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
