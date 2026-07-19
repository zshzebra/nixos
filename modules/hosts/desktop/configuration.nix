{
  self,
  ...
}:
{

  flake.nixosModules.desktopConfiguration =
    { ... }:
    {

      imports = [
        self.nixosModules.desktopHardware
      ];

      networking.hostName = "desktop";

      virtualisation.docker.enable = true;

      system.stateVersion = "25.11";

    };

}
