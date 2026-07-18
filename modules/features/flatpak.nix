{
  inputs,
  ...
}:
{
  flake.nixosModules.flatpak =
    { pkgs, ... }:
    {

      services.flatpak = {
        enable = true;
        package = inputs.nixpkgs-flatpak.legacyPackages.${pkgs.system}.flatpak;
      };

    };
}
