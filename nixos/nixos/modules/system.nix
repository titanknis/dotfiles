{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable nix flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Timezone and Locale Settings
  time.timeZone = "Africa/Tunis"; # Set the correct timezone
  i18n.defaultLocale = "en_US.UTF-8"; # Set system locale

  # XKB keyboard layout
  # services.xserver.xkb = {
  #   layout = "us,us,fr"; # Set the keyboard layout to US
  #   variant = "colemak_dh";
  #   options = "grp:win_space_toggle";
  # };

  # console keymap
  console = {
    keyMap = "mod-dh-ansi-us";
    earlySetup = true;
    # useXkbConfig = true;
  };
}
