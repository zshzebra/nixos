{
  flake.nixosModules.emeetPixy = {
    services.udev.extraRules = ''
      ACTION!="remove", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="328f", ATTRS{idProduct}=="00c0", MODE="0660", GROUP="video", TAG+="uaccess"
    '';
  };
}
