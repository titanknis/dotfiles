# ~/.zshrc - Minimal Zsh configuration

# Command history settings
HISTFILE=~/.histfile      # File to save command history
HISTSIZE=1000             # Commands kept in memory
SAVEHIST=1000             # Commands saved to history file

# Enable autocd for easier directory navigation
setopt autocd

# Disable terminal bell (no beeping)
unsetopt beep

# Enable vi keybindings for command-line editing
bindkey -v

# Source custom aliases
source ~/.aliases

fzf_history(){
    print  $(history 0 | fzf --tac --no-sort --exact --height=40% | cut -c7-) 
}
# Register as ZLE widget
zle -N fzf_history
# Bind to Ctrl+R in both vi modes
bindkey -M viins '^_' fzf_history
bindkey -M vicmd '^_' fzf_history
bindkey -M vicmd '/' fzf_history

# Initialize zoxide for directory jumping
eval "$(zoxide init zsh)"

