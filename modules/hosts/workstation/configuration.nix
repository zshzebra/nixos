{
  self,
  inputs,
  mt7927,
  ...
}:
{

  flake.nixosModules.workstationConfiguration =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {

      imports = [
        self.nixosModules.workstationHardware
      ];

      boot.swraid = {
        enable = true;
        mdadmConf = ''
          MAILADDR root
          ARRAY /dev/md/root metadata=1.2 UUID=47a62b48:f4dbeee2:0f903d19:431c843e
        '';
      };

      # Support for fan reading/control
      boot.extraModulePackages = with config.boot.kernelPackages; [ nct6687d ];
      boot.kernelModules = [ "nct6687" ];
      boot.extraModprobeConfig = ''
        options nct6687 fan_config=msi_alt1
      '';

      networking.hostName = "workstation-E40";

      virtualisation.docker.enable = true;

      system.stateVersion = "25.11";

    };

}
