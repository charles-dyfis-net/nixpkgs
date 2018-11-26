import ./make-test.nix ({ lib, ... }:
{
  name = "bees";

  machine = { config, pkgs, ... }: {
    boot.initrd.postDeviceCommands = ''
      ${pkgs.btrfs-progs}/bin/mkfs.btrfs -f -L aux /dev/vdb
    '';
    virtualisation.emptyDiskImages = [ 4096 ];
    fileSystems = lib.mkVMOverride {
      "/home" = {
        device = "/dev/disk/by-label/aux";
        fsType = "btrfs";
      };
    };
    environment.systemPackages = [
      pkgs.btrfs-progs pkgs.bees
    ];
  };

  testScript = ''
    $machine->succeed("dd if=/dev/urandom of=/home/dedup-me-1 bs=1M count=8");
    $machine->succeed("cp --reflink=never /home/dedup-me-1 /home/dedup-me-2");
    $machine->succeed("systemctl --wait start beesd@home.service");
  '';
})
