{ config, pkgs, ... }:

{
  imports =
    [
      ../../common/configuration.nix
      ../../secrets/users-prod.nix
      ./hardware-configuration.nix
    ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      devices = [ "/dev/nvme1n1" "/dev/nvme0n1" ];
    };
   
    # Virtual rescue system boots over fake SATA controllers
    initrd.availableKernelModules = [ "sd_mod" ];
  };

  networking = {
    hostName = "fafprod1";
    hostId = "4e98920a"; # 8 char id used by zfs
  };

  systemd.network = {
    networks."enp35s0".extraConfig = ''
      [Match]
      Name = enp35s0

      [Network]
      Address = 2a01:4f8:10a:4559::1/64
      Gateway = fe80::1

      Address = 116.202.155.226/26
      Gateway = 116.202.155.193
    '';
  };

  services = {
    udev.extraRules = ''
      ACTION=="add|change", KERNEL=="nvme[0-1]n[0-1]", ATTR{queue/scheduler}="none"
    '';
    zfs = {
      trim = {
        enable = true;
        interval = "Tue, 08:00";
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

