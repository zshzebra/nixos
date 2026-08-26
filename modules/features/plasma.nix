{
  flake.nixosModules.plasma = {
    desktop.features = [ "plasma" ];

    services = {
      desktopManager.plasma6.enable = true;

      displayManager.plasma-login-manager.enable = true;
    };
  };
}
