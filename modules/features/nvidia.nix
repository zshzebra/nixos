{ ... }:
{
  flake.nixosModules.nvidia =
    {
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

        package = config.boot.kernelPackages.nvidiaPackages.latest;

        modesetting.enable = true;
      };

      hardware.nvidia-container-toolkit = {
        enable = true;
      };
      virtualisation.docker.daemon.settings.features.cdi = true;

      environment.systemPackages = with pkgs; [
        nvtopPackages.nvidia
      ];
    };
}
