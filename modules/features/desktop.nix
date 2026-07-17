{
  self,
  inputs,
  pkgs,
  ...
}:
{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    {

      services.xserver.enable = true;

      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      services.xserver.xkb.layout = "us";

      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };

      services.flatpak = {
        enable = true;
        package = inputs.nixpkgs-flatpak.legacyPackages.${pkgs.system}.flatpak;
      };

      programs.firefox.enable = true;

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

      environment.systemPackages = with pkgs; [
        resources
        gnomeExtensions.appindicator
        wl-clipboard
      ];

    };
}
