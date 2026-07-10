{ inputs, ... }:
{
  flake.homeModules.helium =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.helium.packages.${pkgs.system}.default
      ];
    };
}
