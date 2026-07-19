{ inputs, self }:
let
  channels = {
    unstable = {
      nixpkgs = inputs.nixpkgs-unstable;
      home-manager = inputs.home-manager-unstable;
      temporary-nix = inputs.temporary-nix-unstable;
    };
    stable = {
      nixpkgs = inputs.nixpkgs-stable;
      home-manager = inputs.home-manager-stable;
      temporary-nix = inputs.temporary-nix-stable;
    };
  };
in
name:
{ modules }:
let
  ch = channels.${name};
in
ch.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs self; };
  modules = modules ++ [
    ch.home-manager.nixosModules.home-manager
    {
      nixpkgs.overlays = [
        (final: prev: {
          temporaryNix = ch.temporary-nix.packages.${prev.stdenv.hostPlatform.system}.default;
        })
      ];
    }
  ];
}
