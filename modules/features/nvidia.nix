{ ... }:
{
  flake.nixosModules.nvidia =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        open = true;

        # NOTE: Use newer NVIDIA driver than 26.05 nixpkgs, until nixpkgs is updated
        # package = config.boot.kernelPackages.nvidiaPackages.latest;
        package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "595.91.07";
          sha256_64bit = "sha256-yiPIjdJLB6GRZE4eEc+3vN11NzBXSa9A+YABiwleYxM=";
          sha256_aarch64 = "sha256-fqkN7ONFXtTeXyu2mQxorrk362Epxq3bz88hhKYQzwQ=";
          openSha256 = "sha256-OB8Epd+qn/WywxsPiFpxEOAzlJqb6I1SyRoV3a8l71k=";
          settingsSha256 = "sha256-QzT8Cw1luuZGP9DUje3HN/0ngiayqHURj+bqPsxlJ5w=";
          persistencedSha256 = "sha256-3JQBaNmkwxvCXv9q8aHKas6VZM/JjLsuilC2t7ET0u0=";
        };

        modesetting.enable = true;
      };

      hardware.nvidia-container-toolkit = {
        enable = true;
      };
      virtualisation.docker.daemon.settings.features.cdi = true;
      systemd.services.nvidia-container-toolkit-cdi-generator.before =
        lib.mkIf config.virtualisation.docker.enable
          [ "docker.service" ];

      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];
    };
}
