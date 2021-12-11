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

  fileSystems."/opt/faf/backups" = {
    device = "//u280176.your-storagebox.de/backup";
    fsType = "cifs";
    options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in ["${automount_opts},credentials=/etc/nixos/secrets/smb-secrets"];
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 16;
}
