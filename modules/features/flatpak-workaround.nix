{
  inputs,
  ...
}:
{
  flake.nixosModules.flatpakWorkaround =
    { pkgs, ... }:
    {

      services.flatpak.package =
        inputs.nixpkgs-flatpak.legacyPackages.${pkgs.stdenv.hostPlatform.system}.flatpak;

    };
}
