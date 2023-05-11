{ config, pkgs, ... }:

{

  boot = {    
    # ZFS Support
    # So it works on native dedicated boot AND the vm rescue system, we
    # tell it to search partition labels instead of the usual IDs
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = true;
    zfs.forceImportAll = true;
    zfs.devNodes = "/dev/disk/by-partlabel";

    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };

    kernel.sysctl = {
      "net.core.rmem_max" = 4194304;
      "net.core.wmem_max" = 1048576;
      "net.core.netdev_budget" = 600;      

      # These were revealed to me in a dream (chatgpt)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.route.flush" = 1;
    };

    kernelParams = [
     "zfs.zfs_arc_max=25769803776"
    ];

    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages; # Use latest kernel

    initrd = {
      # Virtual rescue system boots over fake SATA controllers
      # Also add Intel nic module
      availableKernelModules = [ "sd_mod" "igb" ];

      # Initrd SSH allows getting into the system if the main pool doesn't import
      network = {
        enable = true;
        ssh = {
          enable = true;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDs+LyhedR8+3W2xjQglnL9ZQMkpA/69rE9nyPptcj4a hal@arch"
          ];
          hostKeys = [
            "/etc/nixos/secrets/ssh_host_ed25519_key"
          ];
        };
      };
    };

  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = true;
      autoLoadConntrackHelpers = false; # Incompatible with new kernels
      logRefusedConnections = false;
      rejectPackets = false;
      extraCommands = '' 
        # icmp limitations
        iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP;
        iptables -A INPUT -p icmp -m limit --limit 10/s --limit-burst 50 -j ACCEPT;
        iptables -A INPUT -p icmp -j DROP;

        # Block all fragmented packets
        iptables -A INPUT -f -j DROP
        iptables -A FORWARD -f -j DROP

        # Block packets with overlapping fragments
        iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
        iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
        iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
        iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
      '';
      allowedTCPPorts = [
        80 
        443
        3478
        8001
        8082
        6667
        6697
        8167
        15000
      ];
      allowedUDPPorts = [ # Http3 requires UDP, may be missing things
        3478
      ];
      allowedUDPPortRanges = [ # Coturn may or may not be present. Should probably uncommonize it.
        { from = 10000; to = 20000; }
      ];
    };
  };

  systemd.network.wait-online.anyInterface = true;
  
  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    wget vim ripgrep atool git docker-compose htop nano curl bzip2 zstd (python3.withPackages(ps: with ps; [ PyGithub click zstandard ])) pipenv
  ];

  services = {
    #nscd.enableNsncd = true;
    timesyncd.servers = [
      "ntp1.hetzner.de"
      "ntp2.hetzner.com"
      "ntp3.hetzner.net"
    ];
    journald = {
      extraConfig = ''
        SystemMaxUse=2G
      '';
    };
    zfs = { # Not all our servers may have zfs
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
      settings = {
         passwordAuthentication = false;
      };
    };
    netdata.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      liveRestore = true; # false = daemon stop will stop all containers
      storageDriver = "overlay2";
      logDriver = "journald";
      autoPrune = {
        enable = true;
        flags = [ "-a" ];
      };
    };
  };

  # Attempt at preventing Docker from starting before external replays are mounted
  systemd.services.docker = {
    after = [ "opt-faf-data-content-replays\x2dold.mount" ];
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
        alias faf='docker-compose --compatibility --project-directory /opt/faf -f /opt/faf/docker-compose.yml -f /opt/faf/faf-extra.yml -f /opt/faf/monitoring.yml'
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
      # uid = 1000; fix later
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
        # Needs to run as root because of ZFS utilization
        # Script needs to chown all results to faforever user
        ExecStart = "/bin/sh -c /opt/faf/scripts/backup-faf-db.sh";
      };
      path = [ pkgs.bash pkgs.zfs pkgs.zstd pkgs.python3 pkgs.pipenv ];
    };
    update-leaderboard-inactives = {
      serviceConfig = {
        ExecStart = "/bin/sh -c /opt/faf/scripts/scheduled-leaderboard-purge.sh";
        User = "faforever";
        Group = "faforever";
      };
      path = [ pkgs.bash pkgs.docker ];
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

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "16384";
  }];

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n.defaultLocale = "en_US.UTF-8";

}
