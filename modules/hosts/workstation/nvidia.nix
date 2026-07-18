{ ... }:
{
  flake.nixosModules.workstationNvidia =
    { ... }:
    {
      # Ensure iGPU for display
      services.xserver.videoDrivers = [ "amdgpu" ];

      hardware.nvidia = {
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
    };
}
