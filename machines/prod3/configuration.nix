{ config, pkgs, ... }:

{
  imports =
    [
      ../../common/configuration.nix
      ../../secrets/networking-prod2.nix
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

  services = {
    k3s = {
      enable = true;
      extraFlags = "--disable traefik";
    };

    #
    # The password in /etc/restic-password is also secured in our Vaultwarden.
    # This config requires an ssh-config for rsync.net for a username and host using <username>.rsync.net.
    # Also, the public key of this root user must be placed in rsync.net (.ssh/authorized_keys)

    restic.backups = {
      backup_config = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/config"
        ];
        repository = "sftp:@rsync.net:restic/config";
        timerConfig = {
          OnCalendar = "04:00";
        };
      };

      maps = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/data/maps"
        ];
        repository = "sftp:@rsync.net:restic/maps";
        timerConfig = {
          OnCalendar = "04:05";
        };
      };

      mods = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/data/mods"
        ];
        repository = "sftp:@rsync.net:restic/mods";
        timerConfig = {
          OnCalendar = "04:15";
        };
      };

      featured_mods = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/data/legacy-featured-mod-files"
        ];
        repository = "sftp:@rsync.net:restic/featured_mods";
        timerConfig = {
          OnCalendar = "04:30";
        };
      };

      nodebb_uploads = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/data/nodebb/uploads"
        ];
        repository = "sftp:@rsync.net:restic/nodebb_uploads";
        timerConfig = {
          OnCalendar = "04:45";
        };
      };

    };
  };

  networking.hostName = "fafprod3";
  networking.hostId = "f4f4f4f4";

  # Initial empty root password for easy login:
  # users.users.root.initialHashedPassword = "";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs+LyhedR8+3W2xjQglnL9ZQMkpA/69rE9nyPptcj4a hal@arch"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqDCEwCJxBeZsI5SyLRNq/5fBhf29p4YEP6IXl8/o7afzTTXVInIl8BW7DkcUbNqZLKFlvvgwREV1dQor8YDkOh/tyubk908IIR+CFYmTEG2eK9zuhDMgpsSYS0VpTr+jHyO9na9gtoq1mqgKG+1N0OhfLl8kGa9YYfJ4+3RjiSZRJAGhoU1KVcJ45a9N5osOXmoaUz8pPg7OnQdftz1LyZzV2fvbMy3ken/puqG77LqZdGNnOXj+F7dyE65c8K4SgvZpsMonpl3fYdVc8AI2MvbC6mvxn9wLltX7z7wRF84fGHmo2JYwSF0XfRUbO+ANv5dj7arC40GKnFiEWIvKr brutus5000@synology"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIDgYjxtGirvoIc63P4TUHDmnXaoWNorPL4m0xJelHayveJc0DbstnwcIwCULTTDOeYTgzexYbCjlpEaABz4lMM9sNdyOQaUj7jn20nPzXAr/nyaTq7wP0klIiOrCvyaEl9eA5IhcwltACPdnDMm+Mr2+v4qyTFJzwVVtyoV42KqWOUzcTfx8/8qlgEbTpih3XX3UeuUtjPQCm8tMDnJiQO4E1UYw6n+fJ9Be4p4tBVbMF7JDn9g3d2DIgfgGWug/n4RMHUNvzLe+X/v8EQZtgNWf1MU7g6xdhWAUDvL75BOJstSDUAgrzPjAqLBpDV+MKAvCctDYKUnpDvGeCXfBn"
  ];

}
