{ ... }:
{
  flake.nixosModules.virt =
    { pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
        # Allow libvirt to access nvidia control files
        qemu.verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/userfaultfd",
            "/dev/nvidiactl", "/dev/nvidia0",
            "/dev/nvidia-modeset", "/dev/nvidia-uvm", "/dev/nvidia-uvm-tools",
            "/dev/nvidia-caps/nvidia-cap1", "/dev/nvidia-caps/nvidia-cap2",
            "/dev/nvidia-caps/nvidia-cap1", "/dev/nvidia-caps/nvidia-cap2",
            "/dev/dri/by-path/pci-0000:01:00.0-card",
            "/dev/dri/by-path/pci-0000:01:00.0-render"
          ]
        '';
      };
      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = true;

      environment.systemPackages = with pkgs; [
        dnsmasq
      ];
    };
}
