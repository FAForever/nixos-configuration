{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/sda" ];
    };
  };

  networking = {
    hostName = "faftest1";
    hostId = "4e98920b"; # 8 char id used by zfs
  };

  systemd.network = {
    networks."ens3".extraConfig = ''
      [Match]
      Name = ens3

      [Network]
      DHCP=ipv4
      Address = 2a01:4f9:c010:7419::/64
      Gateway = fe80::1
    '';
  };

  services = {
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="none"
    '';
  };
  
  virtualisation.docker.storageDriver = pkgs.lib.mkForce "zfs";

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

