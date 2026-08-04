{ ... }:
{
  flake.nixosModules.wireguard =
    { pkgs, ... }:
    {
      networking.wg-quick.interfaces.wg0.configFile = "/etc/wireguard/wg0.conf";

      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];
    };
}
