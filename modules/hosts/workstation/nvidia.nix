{ self, inputs, ... }:
{
  flake.nixosModules.workstationNvidia =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      nixpkgs.config.allowUnfree = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Ensure iGPU for display
      services.xserver.videoDrivers = [
        "amdgpu"
        "nvidia"
      ];

      hardware.nvidia = {
        open = true;

        package = config.boot.kernelPackages.nvidiaPackages.latest;

        modesetting.enable = true;

        # TODO: Evaluate if power management is an issue
        powerManagement.enable = true;

        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          amdgpuBusId = "PCI:122:0:0";
          nvidiaBusId = "PCI:1:0:0";
        };
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
