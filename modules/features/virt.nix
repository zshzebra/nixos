{ ... }:
{
  flake.nixosModules.virt =
    { pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      };
      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = true;

      environment.systemPackages = with pkgs; [
        dnsmasq
      ];
    };
}
