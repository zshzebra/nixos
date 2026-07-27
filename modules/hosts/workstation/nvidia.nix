{ ... }:
{
  flake.nixosModules.workstationNvidia =
    { ... }:
    {
      hardware.nvidia = {
        # TODO: Evaluate if power management is an issue
        powerManagement.enable = true;
      };
    };
}
