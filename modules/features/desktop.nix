{
  flake.nixosModules.desktop =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      options.desktop.features = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };

      config = {
        services.xserver.xkb.layout = "us";

        services.pipewire = {
          enable = true;
          pulse.enable = true;
        };

        environment.systemPackages = [ pkgs.wl-clipboard ];

        home-manager.extraSpecialArgs = {
          desktopFeatures = config.desktop.features;
        };
      };
    };
}
