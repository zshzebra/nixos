{
  flake.nixosModules.gnome =
    { pkgs, ... }:
    {

      desktop.features = [ "gnome" ];

      services.xserver.enable = true;

      services.displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };
      services.desktopManager.gnome.enable = true;

      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/shell" = {
              enabled-extensions = [
                "appindicatorsupport@rgcjonas.gmail.com"
              ];
            };
          };
        }
      ];

      programs.nautilus-open-any-terminal = {
        enable = true;
        # TODO: Don't hardcode terminal
        terminal = "ghostty";
      };

      environment.systemPackages = with pkgs; [
        resources
        gnomeExtensions.appindicator

        nautilus-open-any-terminal
        # I always want this with Gnome
        file-roller
      ];

    };
}
