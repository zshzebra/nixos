{ ... }:
{
  flake.nixosModules.nvidiaOffload =
    { config, ... }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          withNvidiaOffload =
            pkg:
            if config.hardware.nvidia.prime.offload.enable or false then
              prev.symlinkJoin {
                name = "${pkg.pname or pkg.name}-nvidia-offload";
                paths = [ pkg ];
                nativeBuildInputs = [ prev.makeWrapper ];
                postBuild = ''
                  wrapProgram $out/bin/${pkg.meta.mainProgram or pkg.pname} \
                    --set __NV_PRIME_RENDER_OFFLOAD 1 \
                    --set __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
                    --set __GLX_VENDOR_LIBRARY_NAME nvidia \
                    --set __VK_LAYER_NV_optimus NVIDIA_only
                '';
              }
            else
              pkg;
        })
      ];
    };
}
