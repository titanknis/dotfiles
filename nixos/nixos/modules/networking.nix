{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Networking Configuration
  networking.hostName = "knixos"; # Set system hostname
  networking.networkmanager.enable = true; # Enable NetworkManager for easier network management

  # Firewall Configuration
  networking.firewall = {
    enable = true;

    # Open ports in the firewall
    allowedTCPPorts = [ ];

    allowedUDPPorts = [ ];

  };
}
