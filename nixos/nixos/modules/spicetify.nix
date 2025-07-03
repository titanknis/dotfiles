{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{

  imports = [ inputs.spicetify-nix.nixosModules.spicetify ];
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      # simpleBeautifulLyrics
      shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];
    theme = spicePkgs.themes.onepunch;
    # colorScheme = "mocha";
  };

  # allow spotify to be installed if you don't have unfree enabled already
  # do not enable duplicate allowUnfreePredicate as the latest will override the previous declaration
  # nixpkgs.config.allowUnfreePredicate =
  #   pkg:
  #   builtins.elem (lib.getName pkg) [
  #     "spotify"
  #   ];
}
