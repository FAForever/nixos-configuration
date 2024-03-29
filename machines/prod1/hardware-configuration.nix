# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "tank";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/zvol/tank/docker";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/162A-A3FD";
      fsType = "vfat";
    };

  fileSystems."/opt/faf" =
    { device = "tank/fafstack";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/faf-db" =
    { device = "tank/mysql";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/mongodb" =
    { device = "tank/mongodb";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/content/replays" =
    { device = "tank/replays";
      fsType = "zfs";
    };

  # SMB Share is called "backup", subfolders can be mounted to use a server for more than one purpose
  # https://docs.hetzner.com/robot/storage-box/access/access-samba-cifs
  fileSystems."/opt/faf/backups" = {
    device = "//u280176.your-storagebox.de/backup";
    fsType = "cifs";
    options = let
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,seal,uid=1002,gid=1000";
      in ["${automount_opts},credentials=/etc/nixos/secrets/bx10-secrets"];
  };

  fileSystems."/opt/faf/data/content/replays-old" = {
    device = "//u308453.your-storagebox.de/backup/replays";
    fsType = "cifs";
    options = let
        automount_opts = "_netdev,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=20s,uid=1002,gid=1000";
      in ["${automount_opts},credentials=/etc/nixos/secrets/bx11-secrets"];
  };

  fileSystems."/mnt/storagebox-bx11" = {
    device = "//u308453.your-storagebox.de/backup";
    fsType = "cifs";
    options = let
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/nixos/secrets/bx11-secrets"];
  };

  swapDevices = [ ];

  #nix.settings.max-jobs = lib.mkDefault 16;
}
