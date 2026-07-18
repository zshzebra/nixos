{ ... }:
{
  flake.nixosModules.vpforce =
    { ... }:
    {
      services.udev.extraRules = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="ffff", ATTRS{idProduct}=="2055", MODE="0660", GROUP="users"
        SUBSYSTEM=="usb", ATTR{idVendor}=="ffff", ATTR{idProduct}=="2055", MODE="0660", GROUP="users"
        SUBSYSTEM=="usb", ATTR{idVendor}=="1209", ATTR{idProduct}=="db42", MODE="0660", GROUP="users"
      '';
    };
}
