{ pkgs, inputs, ... }:
{

  flake.nixosModules.workstationOpenrgb =
    { pkgs, config, ... }:
    let
      pythonEnv = pkgs.python3.withPackages (
        ps: with ps; [
          openrgb-python
          psutil
          nvidia-ml-py
        ]
      );

      openrgb-lighting = pkgs.writeShellScriptBin "openrgb-lighting" ''
        exec ${pythonEnv}/bin/python ${./openrgb-lighting.py} "$@"
      '';
    in
    {
      services.hardware.openrgb = {
        enable = true;
        motherboard = "amd";
        package = pkgs.openrgb.overrideAttrs (old: {
          version = "1.0rc2-unstable-2026-05-18";

          src = pkgs.fetchFromGitLab {
            owner = "CalcProgrammer1";
            repo = "OpenRGB";
            rev = "2eb569912b221f46faabfb07b9669d0e81e9af1a";
            hash = "sha256-0Opz0qzNOsRS9E/VXeaks3Oz3ba22R08/tpUxMH5tG4=";
          };

          patches =
            (builtins.filter (p: !(builtins.match ".*Install-systemd-service.*" (toString p) != null)) (
              old.patches or [ ]
            ))
            ++ [ ./openrgb-x870e-tomahawk-max.patch ];
        });
      };

      systemd.services.openrgb-lighting = {
        description = "OpenRGB workstation lighting controller";
        wantedBy = [ "multi-user.target" ];
        after = [
          "multi-user.target"
          "openrgb.service"
        ];
        requires = [ "openrgb.service" ];
        serviceConfig = {
          ExecStartPre = pkgs.writeShellScript "wait-for-openrgb" ''
            # Poll OpenRGB server every 250ms for 30s
            for i in $(seq 1 120); do
              if ${pkgs.netcat-gnu}/bin/nc -z 127.0.0.1 6742; then
                echo "OpenRGB is up"
                exit 0
              fi
              sleep 0.25
            done
            echo "OpenRGB not ready after 30s"
            exit 1
          '';
          ExecStart = "${openrgb-lighting}/bin/openrgb-lighting";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      powerManagement.resumeCommands = ''
        ${pkgs.systemd}/bin/systemctl restart openrgb.service
        ${pkgs.systemd}/bin/systemctl restart openrgb-lighting.service
      '';

    };
}
