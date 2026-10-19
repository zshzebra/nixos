{ lib, ... }:
{
  flake.nixosModules.quickboot =
    { pkgs, ... }:
    {
      boot.loader.timeout = 0;

      boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" ];

      services.displayManager.plasma-login-manager.package =
        let
          orig = pkgs.kdePackages.plasma-login-manager;
          unit = "lib/systemd/system/plasmalogin.service";
        in
        pkgs.symlinkJoin {
          name = "${orig.name}-greeter-before-network";
          paths = [ orig ];
          postBuild = ''
            rm $out/${unit}
            sed '/^After=/s/ *systemd-user-sessions\.service//' ${orig}/${unit} > $out/${unit}
          '';
        };

      systemd.services.plasmalogin.serviceConfig.ExecStartPre = lib.mkForce [
        ""
        "${pkgs.bash}/bin/bash -c 'for i in $(seq 200); do ls -d /sys/bus/pci/devices/0000:01:00.0/drm/card* >/dev/null 2>&1 && exit 0; sleep 0.05; done'"
      ];

      virtualisation.docker.enableOnBoot = false;
      systemd.services.nvidia-container-toolkit-cdi-generator.wantedBy = lib.mkForce [ ];
      systemd.services.nvidia-container-toolkit-cdi-generator.serviceConfig.ExecStartPre = lib.mkForce [
        ""
        "${pkgs.bash}/bin/bash -c 'for i in $(seq 300); do [ -e /dev/nvidia-uvm ] && [ -e /dev/nvidia-modeset ] && [ -e /dev/nvidia0 ] && exit 0; sleep 0.1; done'"
      ];

      systemd.services.plasmalogin.after = lib.mkForce [ ];
      systemd.services.plasmalogin.unitConfig.After = [
        ""
        "systemd-logind.service"
        "getty@tty1.service"
      ];
    };
}
