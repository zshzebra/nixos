{
  flake.nixosModules.pop =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      services.system76-scheduler = {
        enable = true;
      };

      environment.systemPackages = lib.mkIf (builtins.elem "gnome" config.desktop.features) [
        pkgs.gnomeExtensions.pop-shell
      ];
    };
}
