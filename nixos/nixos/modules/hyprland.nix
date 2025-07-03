{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Hyprland
  programs.hyprland.enable = true;
  # Screen lock
  programs.hyprlock.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  xdg.mime.defaultApplications = {
    "text/plain" = "neovim.desktop";
    "application/pdf" = "org.pwmt.zathura.desktop";
    # "application/pdf" = "firefox.desktop";
    "image/gif" = "mpv.desktop";

    "text/html" = "qutebrowser.desktop";
    "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
    "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
  };

  # Wayland-specific environment variables
  environment.sessionVariables = {
    VIDEO_PLAYER = "mpv";
    IMAGE_VIEWER = "imv";
    EDITOR = "nvim";
    FILE_MANAGER = "yazi";
    # BROWSER = "qutebrowser";
  };
  # System packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    # Application launcher for Wayland with plugins
    (rofi-wayland.override {
      plugins = [
        rofi-emoji # currently i am just using my script at ~/.config/hypr/scripts/emojipicker.sh
        rofi-calc
      ];
    })

    # dmenu-wayland
    waybar # Bar
    libnotify
    mako # Notification daemon
    swww # wallpaper daemon
    cliphist # clipboard manager

    hyprpolkitagent # Authentication agent

    brightnessctl # Backlight
    playerctl # Media player control
    pavucontrol # PulseAudio Volume Control(sound graphical interface)
    networkmanagerapplet # Network management

    # Hyprland-specific
    hyprpicker
    xdg-desktop-portal-hyprland

    # Terminal and applications
    kitty # Terminal emulator
    cmus # Music player
    rmpc
    mpv # Video player
    imv # image viewer
    zathura # pdf viewer
    yazi # file manager
    # xfce.thunar

    # Wayland-specific tools
    wl-clipboard # Wayland clipboard utilities
    grim # Screenshot utility
    slurp # Area selection tool

    poppler_utils
    tesseract
    ocrfeeder

    batsignal # notify on low battery
    # pywal16
    # wallust
  ];
}
