{ config, pkgs, ... }:

{
  imports =
    [
      ../../common/configuration.nix
      ../../secrets/users-prod.nix
      ./hardware-configuration.nix
    ];


  boot.loader = {
    systemd-boot.enable = false;

    grub = {
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

  };

  networking.hostName = "fafprod3";
  networking.hostId = "f4f4f4f4";

  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs+LyhedR8+3W2xjQglnL9ZQMkpA/69rE9nyPptcj4a hal@arch"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIDgYjxtGirvoIc63P4TUHDmnXaoWNorPL4m0xJelHayveJc0DbstnwcIwCULTTDOeYTgzexYbCjlpEaABz4lMM9sNdyOQaUj7jn20nPzXAr/nyaTq7wP0klIiOrCvyaEl9eA5IhcwltACPdnDMm+Mr2+v4qyTFJzwVVtyoV42KqWOUzcTfx8/8qlgEbTpih3XX3UeuUtjPQCm8tMDnJiQO4E1UYw6n+fJ9Be4p4tBVbMF7JDn9g3d2DIgfgGWug/n4RMHUNvzLe+X/v8EQZtgNWf1MU7g6xdhWAUDvL75BOJstSDUAgrzPjAqLBpDV+MKAvCctDYKUnpDvGeCXfBn Brutus5000@SURFACE"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqDCEwCJxBeZsI5SyLRNq/5fBhf29p4YEP6IXl8/o7afzTTXVInIl8BW7DkcUbNqZLKFlvvgwREV1dQor8YDkOh/tyubk908IIR+CFYmTEG2eK9zuhDMgpsSYS0VpTr+jHyO9na9gtoq1mqgKG+1N0OhfLl8kGa9YYfJ4+3RjiSZRJAGhoU1KVcJ45a9N5osOXmoaUz8pPg7OnQdftz1LyZzV2fvbMy3ken/puqG77LqZdGNnOXj+F7dyE65c8K4SgvZpsMonpl3fYdVc8AI2MvbC6mvxn9wLltX7z7wRF84fGHmo2JYwSF0XfRUbO+ANv5dj7arC40GKnFiEWIvKr brutus5000@synology"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIDgYjxtGirvoIc63P4TUHDmnXaoWNorPL4m0xJelHayveJc0DbstnwcIwCULTTDOeYTgzexYbCjlpEaABz4lMM9sNdyOQaUj7jn20nPzXAr/nyaTq7wP0klIiOrCvyaEl9eA5IhcwltACPdnDMm+Mr2+v4qyTFJzwVVtyoV42KqWOUzcTfx8/8qlgEbTpih3XX3UeuUtjPQCm8tMDnJiQO4E1UYw6n+fJ9Be4p4tBVbMF7JDn9g3d2DIgfgGWug/n4RMHUNvzLe+X/v8EQZtgNWf1MU7g6xdhWAUDvL75BOJstSDUAgrzPjAqLBpDV+MKAvCctDYKUnpDvGeCXfBn"
  ];

  services.openssh.enable = true;

}
