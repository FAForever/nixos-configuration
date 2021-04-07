{ config, pkgs, ... }:

{

  boot = {    
    # ZFS Support
    # So it works on native dedicated boot AND the vm rescue system, we
    # tell it to search partition labels instead of the usual IDs
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = true;
    zfs.devNodes = "/dev/disk/by-partlabel";

    cleanTmpDir = true;
    tmpOnTmpfs = true;

    kernel.sysctl = {
      "net.core.rmem_max" = 4194304;
      "net.core.wmem_max" = 1048576;
      "net.core.netdev_budget" = 600;
    };

    kernelPackages = pkgs.linuxPackages_5_10;
  };

  boot.initrd.network = {
    enable = true;
    ssh.enable = false;
  };

  networking = {
    useDHCP = false;
    firewall = {
      enable = true;
      logRefusedConnections = false;
      allowPing = false;
      rejectPackets = false;
      allowedTCPPorts = [
        80 443
        3478
      ];
      allowedUDPPorts = [
        3478
      ];
      allowedUDPPortRanges = [

      ];
    };
  };

  systemd.network.enable = true;

  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    wget vim ripgrep atool git docker-compose htop nano curl bzip2 zstd (python3.withPackages(ps: with ps; [ PyGithub click zstandard ]))
  ];

  services = {
    journald = {
      extraConfig = ''
        SystemMaxUse=500M
      ''
    };
    zfs = {
      autoScrub = {
        enable = true;
        interval = "Tue, 08:00";
      };
      autoSnapshot = {
        enable = true;
        frequent = 0;
        hourly = 0;
        daily = 3;
        weekly = 1;
        monthly = 1;
      };
    };
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      liveRestore = false; # Docker daemon stop will stop all containers
      storageDriver = "overlay2";
      logDriver = "journald";
      autoPrune = {
        enable = true;
        flags = [ "-a" ];
      };
    };
  };

  programs = {
    tmux = {
      enable = true;
      newSession = true;
    };
    command-not-found.enable = true;
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
      '';
      promptInit = "";
    };
    nano.nanorc = ''
      set nowrap
    '';
  };

  users = {
    defaultUserShell = pkgs.zsh;
    
    groups.faforever = {
      gid = 1000;
    };

    users.faforever = {
      isNormalUser = true;
      extraGroups = [ "docker" ];
      group = "faforever";
    };
  };
  
  nix = {
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 60d";
    };
  };

  systemd.services = {
    db-backup = {
      serviceConfig = {
        ExecStart = "/bin/sh -c /opt/faf/scripts/backup-faf-db.sh";
        User = "faforever";
        Group = "faforever";
      };
      path = [ pkgs.bash pkgs.docker pkgs.bzip2 ];
    };
    update-leaderboard-inactives = {
      serviceConfig = {
        ExecStart = "/bin/sh -c /opt/faf/scripts/scheduled-leaderboard-purge.sh";
        User = "faforever";
        Group = "faforever";
      };
      path = [ pkgs.bash pkgs.docker pkgs.bzip2 ];
    };
  };

  systemd.timers = {
    db-backup = {
      timerConfig = {
        Unit = "db-backup.service";
        OnCalendar = "2:00:00";
      };
      wantedBy = [ "timers.target" ];
    };
    update-leaderboard-inactives = {
      timerConfig = {
        Unit = "update-leaderboard-inactives.service";
        OnCalendar = "3:00:00";
      };
      wantedBy = [ "timers.target" ];
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";

}
