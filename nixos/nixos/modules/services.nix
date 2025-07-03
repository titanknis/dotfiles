{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Disable the OpenSSH daemon
  services.openssh.enable = false;

  # Input Device Configuration
  services.libinput.enable = true; # Enable touchpad support (default in most desktop managers)

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Audio System Configuration
  services.pipewire.enable = true; # Enable PipeWire (audio system)
  # services.pipewire.pulse.enable = true; # Enable PulseAudio support within PipeWire

  services.mpd = {
    enable = true;
    # musicDirectory = "/home/titanknis/Media/Music";
    # user = "titanknis";
  };

  # Enable bluetooth.
  hardware.bluetooth.enable = true; # Enable Bluetooth
  hardware.bluetooth.powerOnBoot = true; # Power on Bluetooth by default
  services.blueman.enable = true;

  # Display Manager
  services.getty.autologinUser = "titanknis";
  environment = {
    loginShellInit = ''
      if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
         hyprland
      fi
    '';
  };
  # services.displayManager.sddm.enable = true; # Enable SDDM display manager
  # services.displayManager.sddm.wayland.enable = true; # Enable SDDM display manager on wayland session
  # services.displayManager.sddm.autoNumlock = true;
}
