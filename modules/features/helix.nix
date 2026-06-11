{ self, pkgs, ... }:
{
  flake.nixosModules.helix =
    { pkgs, ... }:
    {
      environment = {
        systemPackages = with pkgs; [
          nixd
          nil
        ];
        variables = {
          EDITOR = "hx";
          VISUAL = "hx";
        };
      };
    };
}
