{ self, inputs, ... }:
{

  flake.nixosConfigurations.alex-laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.core
      self.nixosModules.alex-laptopDisk
      self.nixosModules.desktop
      self.nixosModules.gnome
      self.nixosModules.flatpak
      self.nixosModules.alex-laptopConfiguration
      self.nixosModules.intelGraphics
      self.nixosModules.homeManager
      self.nixosModules.userAlex
      self.nixosModules.harmoniaHosts
      self.nixosModules.gnomeRdp
      self.nixosModules.syncthing
    ];
  };

}
