{ self, mkHost, ... }:
{

  flake.nixosConfigurations.workstation = mkHost "unstable" {
    modules = [
      self.nixosModules.core
      self.nixosModules.gnome
      self.nixosModules.firefox
      self.nixosModules.flatpak
      self.nixosModules.flatpakWorkaround
      self.nixosModules.workstationConfiguration
      self.nixosModules.workstationOpenrgb
      self.nixosModules.nvidia
      self.nixosModules.workstationNvidia
      self.nixosModules.workstationMt7927
      self.nixosModules.cuda
      self.nixosModules.steam
      self.nixosModules.vr
      self.nixosModules.tailscale
      self.nixosModules.homeManager
      self.nixosModules.userZshzebra
      self.nixosModules.mcad
      self.nixosModules.three_dp
      self.nixosModules.virt
      self.nixosModules.vpforce
      self.nixosModules.xpadneo
    ];
  };

}
