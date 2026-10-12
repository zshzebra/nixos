{ ... }:
{
  flake.nixosModules.intelGraphics =
    { pkgs, ... }:
    {
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
      ];

      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    };
}
