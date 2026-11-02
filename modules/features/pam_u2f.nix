{
  flake.nixosModules.pam_u2f = {
    security.pam.services = {
      login.u2f.enable = true;
      sudo.u2f.enable = true;
    };
  };
}
