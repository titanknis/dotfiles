{ pkgs, ... }:
{
  # Packages for icons and cursor themes
  home.packages = with pkgs; [
    papirus-icon-theme
    bibata-cursors
  ];

  # GTK Configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice"; # replace with your cursor name
    size = 24;
  };
  gtk.gtk3.extraConfig = {
    "gtk-application-prefer-dark-theme" = true;
  };
  gtk.gtk4.extraConfig = {
    "gtk-application-prefer-dark-theme" = true;
  };

  # Qt Theming
  qt = {
    enable = true;
    platformTheme.name = "adwaita"; # Enables qt5ct/qt6ct theming
  };
}
