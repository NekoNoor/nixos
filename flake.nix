{
  description = "System configuration of cuddles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          boot.initrd.luks.devices."crypt_more".device = "/dev/disk/by-partlabel/part_more";
          boot.kernelModules = [ "it87" ];
          boot.supportedFilesystems = [ "ntfs" ];
          networking.hostName = "nixos";
          fileSystems."/mnt/more" = {
            device = "/dev/disk/by-label/tree_more";
            fsType = "f2fs";
          };
          fileSystems."/mnt/move" = {
            device = "/dev/disk/by-label/tree_move";
            fsType = "ntfs-3g";
            options = [ "rw" "uid=cuddles" "nofail" ];
          };
          fileSystems."/mnt/huge" = {
            device = "/dev/disk/by-label/tree_huge";
            fsType = "btrfs";
          };
        }
        ./configuration.nix
        ./modules/amd.nix
        ./modules/boot.nix
        ./modules/desktop.nix
        ./modules/disks.nix
        ./modules/locale.nix
        ./modules/networking.nix
        ./modules/nvidia.nix
        ./modules/pci-passthrough.nix
      ];
    };
    nixosConfigurations."nixos-laptop" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          networking.hostName = "nixos-laptop";
          console.earlySetup = true;
          console.useXkbConfig = true;
          services.xserver.xkbVariant = "workman";
        }
        ./configuration.nix
        ./modules/amd.nix
        ./modules/boot.nix
        ./modules/desktop.nix
        ./modules/disks.nix
        ./modules/locale.nix
        ./modules/networking.nix
      ];
    };
  };
}
