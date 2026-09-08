{
  flake.nixosModules.harmoniaHosts = {
    nix.settings = {
      extra-substituters = [ "http://workstation-e40.local:5000" ];
      extra-trusted-public-keys = [
        "workstation-E40.local-1:uzz/eMhmvAb6tJpiA9jgAQqL7dDoRDWHAfAoFOhL+PA="
      ];
    };
  };
}
