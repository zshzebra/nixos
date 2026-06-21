{ self, pkgs, ... }:
{
  flake.nixosModules.mcad =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        freecad
      ];
    };
}
