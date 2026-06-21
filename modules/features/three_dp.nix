{ self, pkgs, ... }:
{
  flake.nixosModules.three_dp =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        prusa-slicer
      ];
    };
}
