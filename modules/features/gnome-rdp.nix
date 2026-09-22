{
  flake.nixosModules.gnomeRdp = {
    services.gnome.gnome-remote-desktop.enable = true;
    systemd.services.gnome-remote-desktop = {
      wantedBy = [ "graphical.target" ];
    };
  };
}
