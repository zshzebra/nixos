{ self, ... }:
{
  flake.nixosModules.userAlex =
    { pkgs, ... }:
    {
      imports = [ self.nixosModules.nvidiaOffload ];

      users.users.alex = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
          "libvirt"
        ];
        shell = pkgs.zsh;
      };
      nix.settings.trusted-users = [ "alex" ];

      programs.zsh.enable = true;
      home-manager.users.alex = self.homeModules.alex;
    };
}
