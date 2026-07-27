{ ... }:
{
  flake.nixosModules.quickboot =
    { ... }:
    {
      boot.loader.timeout = 0;

      systemd.services.NetworkManager-wait-online.enable = false;
    };
}
