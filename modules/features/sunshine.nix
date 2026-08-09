{ ... }:
{
  flake.nixosModules.sunshine =
    { ... }:
    {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
      };
    };
}
