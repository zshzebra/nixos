{
  flake.nixosModules.pop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ gnomeExtensions.pop-shell ];

      services.system76-scheduler = {
        enable = true;
      };
    };
}
