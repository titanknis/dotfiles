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

# Initialize zoxide for directory jumping
eval "$(zoxide init zsh)"
