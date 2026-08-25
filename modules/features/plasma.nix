{
  flake.nixosModules.plasma =
    { pkgs, ... }:
    {
      desktop.features = [ "plasma" ];

      services = {
        desktopManager.plasma6.enable = true;

        displayManager.plasma-login-manager.enable = true;
      };

      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        elisa
        konsole
      ];
    };
}
