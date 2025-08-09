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
    "image/gif" = "mpv.desktop";
  };

  # Wayland-specific environment variables
  environment.sessionVariables = {
    VIDEO_PLAYER = "mpv";
    IMAGE_VIEWER = "imv";
    EDITOR = "nvim";
    FILE_MANAGER = "yazi";
  };
  # System packages
  environment.systemPackages = with pkgs; [
    # Core utilities
    (rofi-wayland.override { plugins = [ rofi-calc ]; }) # Application launcher for Wayland with plugins
    waybar # Bar
    mako # Notification daemon
    swww # wallpaper daemon
    cliphist # clipboard manager

    brightnessctl # Backlight
    playerctl # Media player control
    pavucontrol # PulseAudio Volume Control(sound graphical interface)
    networkmanagerapplet # Network management
    batsignal # notify on low battery

    # Hyprland-specific
    hyprpicker
    hyprpolkitagent # Authentication agent
    xdg-desktop-portal-hyprland

    # Terminal and applications
    kitty # Terminal emulator
    mpv # Video player
    imv # image viewer
    zathura # pdf viewer

    # Wayland-specific tools
    wl-clipboard # Wayland clipboard utilities
    grim # Screenshot utility
    slurp # Area selection tool
    tesseract # for image/screenshot text extraction
  ];
}
