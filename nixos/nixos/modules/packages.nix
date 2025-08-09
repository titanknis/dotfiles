{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Programs
  programs = {
    gnupg.agent.enable = true;
    neovim.enable = true;
    yazi.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # System packages
  environment.systemPackages = with pkgs; [
    # Terminal
    kitty
    # shell tools
    stow
    wl-clipboard
    zoxide
    eza
    bat
    fzf
    tldr
    wtype
    libqalculate
    taskwarrior3
    jq

    # Applications
    qutebrowser
    signal-desktop
    mpv
    youtube-music

    # Security & privacy
    (pass.withExtensions (ext: [ ext.pass-otp ]))
    rage
    agenix-cli
    zbar

    # Media tools
    yt-dlp
    ffmpeg
  ];

  # Commented packages for reference
  /*
    # Office Suite
    onlyoffice-bin
    libreoffice

    # Editing
    krita
    nomacs
    obs-studio

    # CLI Tools
    disko
    dust
    libnotify
    asciinema
    asciinema-agg

    # Networking
    aria2
    nload
    bmon
    btop

    # Fun
    sl
    fastfetch
    cmatrix
    asciiquarium
    fortune
    cowsay
    ponysay
    pipes
    figlet
    ninvaders
    hollywood
    cava
    cbonsai
    clock-rs
  */
}
