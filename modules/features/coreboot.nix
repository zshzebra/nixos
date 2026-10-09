{
  flake.nixosModules.coreboot = {
    boot.kernelParams = [ "iomem=relaxed" ];
  };
}
