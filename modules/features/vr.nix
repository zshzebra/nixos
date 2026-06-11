{ ... }:
{
  flake.nixosModules.vr =
    { pkgs, ... }:
    {
      services.wivrn = {
        enable = true;
        autoStart = false;
        package = (pkgs.wivrn.override { cudaSupport = true; });
      };
    };
}
