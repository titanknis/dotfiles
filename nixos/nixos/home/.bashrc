# ~/.bashrc - Minimal Bash configuration

# Enable vi keybindings for command-line editing
set -o vi

# Source custom aliases
source ~/.aliases

# Initialize zoxide for directory jumping
eval "$(zoxide init bash)"
