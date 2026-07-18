{ self, ... }:
{
  flake.nixosModules.core =
    { pkgs, ... }:
    {

      imports = [
        self.nixosModules.helix
        self.nixosModules.fish
        self.nixosModules.direnv
        self.nixosModules.nix-ld
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernel.sysctl."kernel.sysrq" = 1;

      boot.kernelPackages = pkgs.linuxPackages_latest;
      networking.networkmanager.enable = true;

      time.timeZone = "Australia/Sydney";

      i18n.defaultLocale = "en_AU.UTF-8";
      console = {
        font = "Lat2-Terminus16";
      };

      environment.systemPackages = with pkgs; [
        helix
      ];

      services.openssh.enable = true;
      networking.firewall.enable = false;

    };
}
