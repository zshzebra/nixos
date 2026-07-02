{ self, inputs, ... }:
{

  flake.nixosConfigurations.workstation = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.core
      self.nixosModules.desktop
      self.nixosModules.workstationConfiguration
      self.nixosModules.workstationOpenrgb
      self.nixosModules.workstationNvidia
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
    ];
  };

}
