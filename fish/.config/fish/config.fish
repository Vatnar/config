set -gx USER (whoami)
set -gx HOSTNAME (hostname)
function fish_prompt
    # USER@HOST and current directory
    set_color $fish_color_cwd
    printf '%s@%s %s' $USER $HOSTNAME (prompt_pwd)
    set_color normal

    # Prompt symbol
    echo ' > '
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    set fish_greeting

end

starship init fish | source
if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
end

alias pamcan pacman
alias ls 'eza --icons'
alias q 'qs -c ii'

zoxide init fish --cmd cd | source

alias lg 'lazygit'
