{
  self,
  ...
}:
{

  flake.nixosModules.alex-laptopConfiguration =
    { ... }:
    {

      imports = [
        self.nixosModules.alex-laptopHardware
      ];

      networking.hostName = "laptop";

      virtualisation.docker.enable = true;

      system.stateVersion = "25.11";

    };

}
