{ inputs, ... }:
{
  imports = [ inputs.home-manager-stable.flakeModules.home-manager ];

  flake.nixosModules.homeManager =
    { ... }:
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
    };
}
