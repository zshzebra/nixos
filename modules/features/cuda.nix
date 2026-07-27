{ self, pkgs, ... }:
{
  flake.nixosModules.cuda =
    { config, ... }:
    {
      nix.settings = {
        substituters = [
          "https://cache.nixos-cuda.org"
        ];
        trusted-public-keys = [
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];
      };

      nixpkgs.config.cudaSupport = true;

      # Apply fix in nixpkgs pr #545542
      nixpkgs.overlays = [
        (
          final: prev:
          let
            cudaPatch = prev.fetchpatch {
              name = "cuda-setup-hook-nvcc-545542.patch";
              url = "https://github.com/NixOS/nixpkgs/pull/545542.diff?full_index=1";
              hash = "sha256-5U2DTTLvvCOTQJd3wTJIzL/1HFdX0u7w4XGKTOAR0cw=";
            };
            patchScope =
              cudaPkgs:
              cudaPkgs.overrideScope (
                cudaFinal: cudaPrev: {
                  setupCudaHook = cudaPrev.setupCudaHook.overrideAttrs (old: {
                    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.patch ];
                    buildCommand = old.buildCommand + ''
                      patch -p1 "$out/nix-support/setup-hook" < ${cudaPatch}
                    '';
                  });
                }
              );
            needsPatch = prev.lib.versionAtLeast prev.cmake.version "4.3";
          in
          prev.lib.genAttrs [ "cudaPackages_12" "cudaPackages_13" ] (
            name: if needsPatch then patchScope prev.${name} else prev.${name}
          )
        )
      ];
    };
}
