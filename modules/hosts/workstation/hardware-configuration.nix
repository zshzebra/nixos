{ ... }:
{
  flake.nixosModules.workstationHardware =
    {
      config,
      lib,
      modulesPath,
      ...
    }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.includeDefaultModules = false;
      boot.initrd.availableKernelModules = [
        "nvme"
        "raid0"
        "md_mod"
        "xfs"
        "xhci_pci"
        "usbhid"
        "hid_generic"
        "autofs"
        "efivarfs"
      ];
      # AHCI inits in series to avoid drive spin-up current, even without any SATA drives being present
      boot.blacklistedKernelModules = [ "ahci" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/e7c3bc91-e425-432e-8440-a59925bcea99";
        fsType = "xfs";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/E093-ED4A";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
      boot.swraid.enable = true;

    };
}
