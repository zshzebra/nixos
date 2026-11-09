{
  flake.nixosModules.workstationGpuDma =
    { config, lib, ... }:
    {
      hardware.nvidia.package = lib.mkForce (
        config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "595.91.07";
          sha256_64bit = "sha256-yiPIjdJLB6GRZE4eEc+3vN11NzBXSa9A+YABiwleYxM=";
          sha256_aarch64 = "sha256-fqkN7ONFXtTeXyu2mQxorrk362Epxq3bz88hhKYQzwQ=";
          openSha256 = "sha256-OB8Epd+qn/WywxsPiFpxEOAzlJqb6I1SyRoV3a8l71k=";
          settingsSha256 = "sha256-QzT8Cw1luuZGP9DUje3HN/0ngiayqHURj+bqPsxlJ5w=";
          persistencedSha256 = "sha256-3JQBaNmkwxvCXv9q8aHKas6VZM/JjLsuilC2t7ET0u0=";
          patchesOpen = [
            ./patches/nvidia-open-595.91.07-drm-disable-iomap-wc.patch
          ];
        }
      );

      boot.extraModprobeConfig = ''
        options nvidia-drm disable_iomap_wc=1
        options nvidia NVreg_RegistryDwords="RMForceStaticBar1=1;RmForceDisableIomapWC=1"
      '';
    };
}
