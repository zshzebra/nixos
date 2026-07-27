{ inputs, ... }:
{
  flake.nixosModules.zed =
    { ... }:
    {
      nix.settings = {
        substituters = [ "https://zed.cachix.org" ];
        trusted-public-keys = [ "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU=" ];
      };
      nixpkgs.overlays = [
        (final: prev: {
          zed-editor = inputs.zed.packages.${prev.stdenv.hostPlatform.system}.default;
        })
      ];
    };
}
