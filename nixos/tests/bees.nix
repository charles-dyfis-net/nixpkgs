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
    services.beesd.filesystems = {
      aux = {
        spec = "LABEL=aux";
        hashTableSizeMB = 16;
      };
    };
  };

  testScript = ''
    $machine->succeed("systemctl stop beesd\@aux.service");
    $machine->succeed("dd if=/dev/urandom of=/home/dedup-me-1 bs=1M count=8");
    $machine->succeed("cp --reflink=never /home/dedup-me-1 /home/dedup-me-2");
    $machine->succeed("sync");

    # must recognize these files as not sharing any space before we start bees
    $machine->fail(q([[ $(btrfs fi du -s --raw /home/dedup-me-{1,2} | awk 'NR>1 { print $3 }' | grep -E '^0$' | wc -l) -eq 0 ]]));
    $machine->succeed("systemctl start beesd\@aux.service");

    # FIXME: Need to do a better job at polling
    $machine->succeed("sleep 10");

    # assert that "Set Shared" column is nonzero
    $machine->succeed(q([[ $(btrfs fi du -s --raw /home/dedup-me-{1,2} | awk 'NR>1 { print $3 }' | grep -E '^0$' | wc -l) -eq 0 ]]));
  '';
})
