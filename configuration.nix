{ config, pkgs, ... }:

{

  # This file simply exists for you to pick which host we want to deploy
  imports =
    [
      ./machines/prod1/configuration.nix
      #./machines/test1/configuration.nix
    ];

}
