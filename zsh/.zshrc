# Source the zinit framework
source "${ZDOTDIR:-$HOME}/.local/share/zinit/zinit.git/zinit.zsh"

# Load plugins
zinit wait lucid light-mode for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    junegunn/fzf

export EDITOR=nvim
# Your custom aliases
alias pamcan='pacman'
alias ls='eza --icons'
alias q='qs -c ii'
alias lg='lazygit'

nvim() {
    if [ $# -eq 0 ]; then
        command nvim .
    else
        command nvim "$@"
    fi
}
# Zsh-specific options and configurations
# Disable some globbing options to prevent errors with certain commands
setopt no_glob_subst
setopt interactive_comments
setopt prompt_subst
setopt extendedglob

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
setopt INC_APPEND_HISTORY   
setopt SHARE_HISTORY       
setopt HIST_IGNORE_DUPS   
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS 
setopt HIST_VERIFY
setopt HIST_IGNORE_SPACE

fh() {
    history 1 | fzf --tac
}

alias cat='bat --style=plain --paging=never'
alias catt='bat --style=full'
alias gl='git log --all --oneline --graph --decorate'
alias gla='git log --all --graph --decorate --pretty=format:"%h|%an|%s" | column -t -s "|"'
alias gs='git switch $(git branch | fzf)'



sf() {
    fd --type f . | fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}'
}

alias cheat='curl cheat.sh/'
# Starship prompt configuration
# This is the Zsh equivalent of `starship init fish`
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
zinit light zsh-users/zsh-syntax-highlighting


source ~/zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
