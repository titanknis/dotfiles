{
  config,
  lib,
  pkgs,
  ...
}:
{
  # GPG Configuration
  programs.gnupg.agent = {
    enable = true; # Enable the GPG agent
    enableSSHSupport = true; # Enable GPG for SSH key management
  };

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    # noto-fonts
    # nerd-fonts.fira-code
    # inter-nerdfont
  ];

  programs.tmux = {
    enable = true;
    # plugins = with pkgs.tmuxPlugins; [
    #   sensible
    # ];
  };

  # Web Browser
  programs.firefox.enable = true;
  # Email Client
  programs.thunderbird.enable = true;
  # Editor
  programs.neovim.enable = true;
  # File Manager
  programs.yazi.enable = true;
  # Version control
  programs.git.enable = true;

  # programs.ydotool.enable = true;

  # Installed System Packages
  environment.systemPackages = with pkgs; [
    # home-manager
    # Terminal
    kitty # Terminal emulator
    qutebrowser # mouseless browser

    taskwarrior3
    taskwarrior-tui

    stow
    (pass.withExtensions (ext: [ ext.pass-otp ])) # Pass with OTP extension
    zbar
    wtype

    # Media
    mpv # Video player
    cmus # Music player
    youtube-music

    komikku # managa reader

    # archieve managers
    file-roller
    # ark
    # peazip

    # Office Suite
    # libreoffice
    onlyoffice-bin
    libreoffice

    # Editing
    # krita
    # nomacs

    # xfce.thunar # gui file manager for drag and drop feature

    # CLI Utilities
    # img2pdf
    wl-clipboard # Clipboard manager
    yt-dlp
    spotdl
    # tree # Directory tree

    # Networking & Monitoring
    # wget # Download tool (better for resuming downloads)
    # curl # Download tool (supports more protocols)
    aria2
    nload
    bmon
    btop
    # htop
    # gtop

    zoxide # Directory jumper
    eza # Enhanced ls
    bat # Syntax-highlighted cat
    fzf # Fuzzy finder
    ripgrep
    # unzip # .zip file extractor

    # parted
    disko
    dust # nice to quickly see storage usage

    tldr
    # man
    # man-pages
    tgpt

    # asciinema # usefull for recording terminal process gif
    # asciinema-agg

    ffmpeg
    libqalculate # calculator cli
    jq

    # Fun and Miscellaneous
    fastfetch # Display system info in a visually appealing way
    sl # Steam locomotive animation in terminal
    cmatrix # Matrix effect in terminal
    asciiquarium # Watch an aquarium in terminal
    cowsay # ASCII cowspeak for fun messages
    ponysay # Pony-themed version of cowsay
    fortune # Display random quotes
    pipes # Animated pipes in terminal
    figlet # Generate ASCII art text
    ninvaders
    hollywood
    cava
    cbonsai
    # cool-retro-term

    # Clock and Timers
    clock-rs
    # tty-clock

    cheese
    obs-studio

    # Unfree Software
    discord # Communication platform
    # vscode
  ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # Add additional package names here
      "discord" # Allow Discord :(
      "spotify"
      # "vscode"
    ];
}
