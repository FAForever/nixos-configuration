# Import the NixOS options
{ config, lib, pkgs, ... }:

let
  hostConfigPath = "/etc/nixos/machines/" + (lib.removeSuffix "\n" (builtins.readFile "/etc/nixos/host")) + "/configuration.nix";
  importedConfig = import hostConfigPath;
in
{
  imports =
    [ importedConfig ];
}
