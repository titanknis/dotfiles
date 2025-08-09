{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable channel

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # This helper function takes all the inputs we need for a host
      mkHost =
        { hostname, username }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              system
              username
              hostname
              ;
          };
          modules = [
            # Machine's configuration.nix
            ./hosts/${hostname}/configuration.nix

            # Other modules
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            {
              home-manager.extraSpecialArgs = {
                inherit
                  username
                  inputs
                  hostname
                  ;
              };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./hosts/${hostname}/home.nix;

              # The state version is required and should stay at the version you
              # originally installed.
              system.stateVersion = "25.05"; # Did you read the comment?
              # system.stateVersion = "25.11"; # Did you read the comment?
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        asus = mkHost {
          hostname = "asus";
          username = "titanknis";
        };

        hp = mkHost {
          hostname = "hp";
          username = "titanknis";
        };

        usb = mkHost {
          hostname = "usb";
          username = "titanknis";
        };

        vm = mkHost {
          hostname = "vm";
          username = "titanknis";
        };
      };
    };
}
