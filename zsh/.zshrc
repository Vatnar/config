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


export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border
  --inline-info
  --preview-window=right:60%:wrap
"

export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {}'
"

export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {}'
"

fh() {
    history 1 | fzf --tac
}

alias cat='bat --style=plain --paging=never'
alias catt='bat --style=full'
alias gl='git log --all --oneline --graph --decorate'
alias gla='git log --all --graph --decorate --pretty=format:"%h|%an|%s" | column -t -s "|"'
alias gs='git switch $(git branch | fzf)'

gbd() {
    git branch | fzf --multi --preview 'git log --oneline --graph --color=always {}' | xargs -r git branch -D
}

gdf() {
    git diff --name-only | fzf --preview 'git diff --color=always {}' | xargs -r git diff
}

gst() {
    git stash list | fzf --preview 'git stash show -p {1}' | cut -d: -f1 | xargs -r git stash pop
}


fkill() {
    local pids
    pids=$(ps -ef | fzf --header-lines=1 --multi | awk '{print $2}')
    [[ -n "$pids" ]] && echo "$pids" | xargs kill -9
}


fenv() {
    printenv | fzf --preview 'echo {}' | cut -d= -f1
}



fe() {
    fd --type f . | fzf --preview 'bat --color=always --style=numbers {}' --bind 'enter:become($EDITOR {})'
}

fman() {
    man -k . | fzf --preview 'echo {} | awk "{print \$1}" | xargs man' | awk '{print $1}' | xargs -r man
}

falias() {
    {
        echo "# Aliases"
        alias | sed 's/=/ → /' 
        echo ""
        echo "# Functions"
        print -l ${(ok)functions} | while read -r fn; do
            local def=$(whence -f "$fn" | head -n 5 | tail -n +2)
            echo "$fn → ${def%%$'\n'*}"
        done
    } | fzf --preview '
        cmd=$(echo {} | cut -d" " -f1)
        type "$cmd" 2>/dev/null || whence -f "$cmd" 2>/dev/null
    ' --preview-window=right:60%:wrap --header='Aliases & Functions' | cut -d' ' -f1
}

# === Custom Commands Cheatsheet ===
# fh          → Fuzzy search command history
# fkill       → Kill processes interactively
# fe          → Fuzzy file edit
# fman        → Fuzzy man page search
# fenv        → Browse environment variables
# gbd         → Delete git branches (multi-select)
# gdf         → Fuzzy git diff by file
# gst         → Fuzzy stash browser
# cf          → Fuzzy file switch CD like

cf() {
    local file
    file=$(fd . --type f | fzf --preview "head -20 {}") || return
    cd "$(dirname "$file")"
}



cheat() {
    grep -E '^# [a-z]+ *→' ~/.zshrc | sed 's/^# //' | column -t -s '→' | bat --style=plain --language=txt
}

# Starship prompt configuration
# This is the Zsh equivalent of `starship init fish`
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
zinit light zsh-users/zsh-syntax-highlighting

export PATH="$PATH:/home/vatnar/.local/share/JetBrains/Toolbox/apps/clion/bin/"
export PATH="$PATH:/home/vatnar/.dotnet/tools"
source ~/zsh-syntax-highlighting/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh
