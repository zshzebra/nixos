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
          "libvirtd"
          "uinput"
          "dialout"
        ];
        shell = pkgs.fish;
      };
      nix.settings.trusted-users = [ "zshzebra" ];

      programs.fish.enable = true;
      home-manager.users.zshzebra = self.homeModules.zshzebra;
    };
}
