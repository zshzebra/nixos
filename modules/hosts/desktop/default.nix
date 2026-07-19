{ self, mkHost, ... }:
{

  flake.nixosConfigurations.desktop = mkHost "stable" {
    modules = [
      self.nixosModules.core
      self.nixosModules.desktopDisk
      self.nixosModules.gnome
      self.nixosModules.flatpak
      self.nixosModules.desktopConfiguration
      self.nixosModules.nvidia
      self.nixosModules.cuda
      self.nixosModules.steam
      self.nixosModules.homeManager
      self.nixosModules.userAlex
    ];
  };

}
