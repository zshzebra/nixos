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
      boot.extraModulePackages = with config.boot.kernelPackages; [
        (nct6687d.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "Fred78290";
            repo = "nct6687d";
            rev = "5f12dd1b0b3c8f79f31d309749862d986ff9efa7";
            sha256 = "sha256-tg/k3x5gwGzSTUkS8sDfCE4yx+GgAg0s8PeaiWFnVIc=";
          };
        }))
      ];
      boot.extraModprobeConfig = ''
        options nct6687 fan_config=msi_alt1
      '';
      # Driver is not critical, defer loading
      systemd.services.nct6687-load = {
        description = "Load nct6687 kernel module";
        wantedBy = [ "multi-user.target" ];
        after = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.kmod}/bin/modprobe nct6687";
        };
      };

      networking.hostName = "workstation-E40";

      virtualisation.docker.enable = true;

      system.stateVersion = "25.11";

    };

}
