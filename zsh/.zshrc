source "${ZDOTDIR:-$HOME}/.local/share/zinit/zinit.git/zinit.zsh"
export PATH="/usr/local/bin:$PATH"

zinit wait lucid light-mode for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-history-substring-search \
    junegunn/fzf

export EDITOR=nvim
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza -l --icons --sort=newest'
alias lo='eza -l --icons --sort=oldest'
alias ltd='eza -l --icons --sort=modified'
alias ltree='eza --tree --level=2 --icons'

ghostty-toggle() {
  config="$HOME/.config/ghostty/config"
  current=$(grep --color=never "^theme = " "$config" | cut -d' ' -f3)

  if [[ "$current" == "catppuccin-mocha.conf" ]]; then
    sed -i 's/theme = catppuccin-mocha.conf/theme = catppuccin-latte.conf/' "$config"
    echo "Switched to light theme (catppuccin-latte) - restart Ghostty to apply"
  else
    sed -i 's/theme = catppuccin-latte.conf/theme = catppuccin-mocha.conf/' "$config"
    echo "Switched to dark theme (catppuccin-mocha) - restart Ghostty to apply"
  fi
}

alias _fixdisplay='xrandr --output DP-0 --mode 2560x1440 --rate 180.00 --right-of HDMI-0 --auto'

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

fhe() {
    local cmd
    cmd=$(fc -ln 1 | fzf --tac) || return
    [[ -n "$cmd" ]] && eval "$cmd"
}

alias cat='bat --style=plain --paging=never'

help() {
    local blue=$'\033[0;34m'
    local green=$'\033[0;32m'
    local yellow=$'\033[0;33m'
    local magenta=$'\033[0;35m'
    local nc=$'\033[0m'

    printf "${blue}%-13s${nc} → %s\n" "fe" "fuzzy file edit"
    printf "${blue}%-13s${nc} → %s\n" "ff" "fuzzy find folder (cd to dir)"
    printf "${blue}%-13s${nc} → %s\n" "fh" "fuzzy search command history"
    printf "${blue}%-13s${nc} → %s\n" "fhe" "fuzzy execute history command"
    printf "${blue}%-13s${nc} → %s\n" "fkill" "kill processes interactively"
    printf "${blue}%-13s${nc} → %s\n" "fman" "fuzzy man page search"
    printf "${blue}%-13s${nc} → %s\n" "fenv" "browse environment variables"
    printf "${green}%-13s${nc} → %s\n" "ls/ll/la" "eza file listing (short/long/all)"
    printf "${green}%-13s${nc} → %s\n" "lt/lo/ltd" "eza sorted by time (newest/oldest/modified)"
    printf "${green}%-13s${nc} → %s\n" "ltree" "tree view of directory"
    printf "${green}%-13s${nc} → %s\n" "cat/catt" "bat plain/full output"
    printf "${yellow}%-13s${nc} → %s\n" "gl/glh/glt" "git log (all/head/tail)"
    printf "${yellow}%-13s${nc} → %s\n" "gla/glp" "git log (author/pager)"
    printf "${yellow}%-13s${nc} → %s\n" "gs" "git switch branch (fzf)"
    printf "${yellow}%-13s${nc} → %s\n" "gdf" "fuzzy diff unstaged files"
    printf "${magenta}%-13s${nc} → %s\n" "_fixdisplay" "xrandr dual monitor setup"
}
alias catt='bat --style=full'
alias gl='git log --all --oneline --graph --decorate'
alias glh='git log --all --oneline --graph --decorate --color=always | head'
alias glt='git log --all --oneline --graph --decorate --color=always | tail'
alias gla='git log --all --graph --decorate --pretty=format:"%h|%an|%s" --color=always | column -t -s "|" | bat --color=always | less -R'
alias glp='git log --all --oneline --graph --decorate | less -R'
gs() {
    local branch
    branch=$(git branch --format='%(refname:short)' | fzf) || return
    [[ -n "$branch" ]] && git switch "$branch"
}


gdf() {
    git diff --name-only | fzf --preview 'git diff --color=always {}' | xargs -r git diff
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


ff() {
    local file
    file=$(fd . --type f | fzf --preview "head -20 {}") || return
    cd "$(dirname "$file")"
}




zstyle ':completion:*' menu select
autoload -Uz compinit && compinit


# Starship prompt configuration
# This is the Zsh equivalent of `starship init fish`
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"
zinit light zsh-users/zsh-syntax-highlighting

export PATH="$PATH:/home/vatnar/.local/share/JetBrains/Toolbox/apps/clion/bin/"
source ~/.config/zsh/zsh-syntax-highlighting/themes/catppuccin_frappe-zsh-syntax-highlighting.zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/tools/realesrgan-ncnn-vulkan-*/:$PATH"



#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH="/home/vatnar/dev/src/flutter/bin:$PATH"
export CHROME_EXECUTABLE=/usr/bin/vivaldi-stable
export PATH=/usr/local/cuda-12.8/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64:$LD_LIBRARY_PATH
export PATH=/home/vatnar/.miniconda3/bin:$PATH

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# opencode
export PATH=/home/vatnar/.opencode/bin:$PATH
