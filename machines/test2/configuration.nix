{ config, pkgs, ... }:

{
  imports =
    [
      ../../secrets/users-test.nix
      ./hardware-configuration.nix
    ];

  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because GRUB2 has a NixOS module for dual EFI partitions
  boot.loader.systemd-boot.enable = false;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      {
       devices = [ "nodev" ];
       path = "/boot1";
      }
      {
       devices = [ "nodev" ];
       path = "/boot2";
      }
    ];
    copyKernels = true;
  };

  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "faftest2";
  networking.hostId = "faf2f4f5";

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = true;
  networking.usePredictableInterfaceNames = false;
  networking.interfaces."eth0".ipv4.addresses = [
    {
      address = "88.99.240.117";
      prefixLength = 26;
    }
  ];
  networking.defaultGateway = "88.99.240.65";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "eth0"; };
  networking.nameservers = [ "8.8.8.8" ];

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs+LyhedR8+3W2xjQglnL9ZQMkpA/69rE9nyPptcj4a hal@arch"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIDgYjxtGirvoIc63P4TUHDmnXaoWNorPL4m0xJelHayveJc0DbstnwcIwCULTTDOeYTgzexYbCjlpEaABz4lMM9sNdyOQaUj7jn20nPzXAr/nyaTq7wP0klIiOrCvyaEl9eA5IhcwltACPdnDMm+Mr2+v4qyTFJzwVVtyoV42KqWOUzcTfx8/8qlgEbTpih3XX3UeuUtjPQCm8tMDnJiQO4E1UYw6n+fJ9Be4p4tBVbMF7JDn9g3d2DIgfgGWug/n4RMHUNvzLe+X/v8EQZtgNWf1MU7g6xdhWAUDvL75BOJstSDUAgrzPjAqLBpDV+MKAvCctDYKUnpDvGeCXfBn Brutus5000@SURFACE"
  ];

  services.openssh.enable = true;

}
