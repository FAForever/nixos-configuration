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
      enable = false;
      efiSupport = true;
      version = 2;
      #devices = [  "/dev/sda1" "/dev/sdb1" ];
      zfsSupport = true;
      devices = [ "nodev" ];
      forceInstall = true;
      fsIdentifier = "label";
    };

    loader = {
      #efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    kernelParams = [ "ip=dhcp" ];

  };

  networking = {
    hostName = "fafprod1";
    hostId = "4e98920a"; # 8 char id used by zfs
  };

  systemd.network = {
    wait-online.anyInterface = true;
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

    coturn = {
      enable = false;
      realm = "faforever.com";
      listening-ips = [
        "116.202.155.226"
      ];
      lt-cred-mech = true;
      #use-auth-secret = true;
      static-auth-secret = "banana";
      extraConfig = ''
        min-port=10000
        max-port=20000 
        fingerprint
        #prometheus
        no-tls
        no-dtls
        #relay-threads=16
        verbose
      '';
    };

    # == Backups to an external services with restic ==
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
          "/opt/faf/data/content/maps"
        ];
        repository = "sftp:@rsync.net:restic/maps";
        timerConfig = {
          OnCalendar = "04:05";
        };
      };

      mods = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/data/content/mods"
        ];
        repository = "sftp:@rsync.net:restic/mods";
        timerConfig = {
          OnCalendar = "04:15";
        };
      };

      featured_mods = {
        passwordFile = "/etc/restic-password";
        paths = [
          "/opt/faf/data/content/legacy-featured-mod-files"
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

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; # Did you read the comment?

}

