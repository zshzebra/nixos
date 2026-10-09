{
  flake.nixosModules.coreboot =
    { pkgs, ... }:
    {
      boot.kernelParams = [ "iomem=relaxed" ];
      boot.initrd.kernelModules = [ "nvme" "md_mod" "raid0" "xfs" ];
      environment.systemPackages = [ pkgs.coreboot-utils ];
      systemd.services.coreboot-boot-ok = {
        wantedBy = [ "graphical.target" ];
        after = [ "display-manager.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.coreboot-utils}/bin/nvramtool -w reboot_counter=0";
        };
      };
    };
}
