{
  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager-stable.url = "github:nix-community/home-manager/release-26.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    temporary-nix-stable.url = "github:zshzebra/temporary-nix";
    temporary-nix-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    temporary-nix-unstable.url = "github:zshzebra/temporary-nix";
    temporary-nix-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    mt7927.url = "github:cmspam/mt7927-nixos";
    mt7927.inputs.nixpkgs.follows = "nixpkgs-unstable";

    helium.url = "github:AlvaroParker/helium-nix";
    helium.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Temporary workaround for issue #535787
    nixpkgs-flatpak.url = "github:nixos/nixpkgs/51effaf9783e0226281ad10e95a4af6c8a145316";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-stable"; # Only for desktop for the moment

  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
