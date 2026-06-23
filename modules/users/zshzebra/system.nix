{ self, ... }:
{
  flake.nixosModules.userZshzebra =
    { pkgs, ... }:
    {
      imports = [ self.nixosModules.nvidiaOffload ];

      users.users.zshzebra = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
          "libvirt"
        ];
        shell = pkgs.fish;
      };
      nix.settings.trusted-users = [ "zshzebra" ];

      programs.fish.enable = true;
      home-manager.users.zshzebra = self.homeModules.zshzebra;
    };
}
