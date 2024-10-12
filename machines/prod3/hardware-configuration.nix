# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "tank/nixos";
      fsType = "zfs";
    };

  fileSystems."/boot2" =
    { device = "/dev/disk/by-uuid/335B-383C";
      fsType = "vfat";
    };

  fileSystems."/boot1" =
    { device = "/dev/disk/by-uuid/335B-1591";
      fsType = "vfat";
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/zvol/tank/nixos/docker";
      fsType = "ext4";
    };

  fileSystems."/var/lib/rancher" =
    { device = "/dev/zvol/tank/nixos/rancher";
      fsType = "ext4";
    };

  fileSystems."/opt/faf" =
    { device = "tank/faf";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/faf-db" =
    { device = "tank/faf/mariadb";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/postgres" =
    { device = "tank/faf/postgres";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/legacy-featured-mod-files" =
    { device = "tank/faf/legacy-featured-mod-files";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/maps" =
    { device = "tank/faf/maps";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/mods" =
    { device = "tank/faf/mods";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/phpbb3" =
    { device = "tank/faf/phpbb3";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/nodebb" =
    { device = "tank/faf/nodebb";
      fsType = "zfs";
    };

  fileSystems."/opt/faf/data/mongodb" =
    { device = "tank/faf/mongodb";
      fsType = "zfs";
    };

#  fileSystems."/opt/k8s-test" =
#    { device = "tank/faf/k8s-test";
#      fsType = "zfs";
#    };


    # SMB Share is called "backup", subfolders can be mounted to use a server for more than one purpose
  # https://docs.hetzner.com/robot/storage-box/access/access-samba-cifs
  fileSystems."/opt/faf/backups" = {
    device = "//u280176.your-storagebox.de/backup";
    fsType = "cifs";
    options = let
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.mount-timeout=5s,seal,uid=1002,gid=1000,vers=3.0";
      in ["${automount_opts},credentials=/etc/nixos/secrets/bx10-secrets"];
  };

  fileSystems."/opt/faf/data/replays-old" = {
    device = "//u308453.your-storagebox.de/backup/replays";
    fsType = "cifs";
    options = let
        automount_opts = "_netdev,x-systemd.idle-timeout=60,x-systemd.mount-timeout=20s,seal,uid=1002,gid=1000,vers=3.0";
      in ["${automount_opts},credentials=/etc/nixos/secrets/bx11-secrets"];
  };


  # TODO: Generate mounts using Nix :) ChatGPT 4  
  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
