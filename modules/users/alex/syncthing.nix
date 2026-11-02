{
  flake.nixosModules.userAlex =
    { config, lib, ... }:
    {
      services.syncthing = lib.mkIf config.services.syncthing.enable {
        user = "alex";
        group = "users";
        dataDir = "/home/alex";
        configDir = "/home/alex/.config/syncthing";
      };
    };
}
