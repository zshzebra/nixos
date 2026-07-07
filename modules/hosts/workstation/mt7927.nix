{ inputs, ... }:
{
  flake.nixosModules.workstationMt7927 =
    { pkgs, ... }:
    {
      imports = [ inputs.mt7927.nixosModules.default ];

      hardware.mediatek-mt7927 = {
        enable = true;
        enableWifi = true;
        enableBluetooth = true;
        disableAspm = true;
      };

      # HACK: Upstream packaging issue
      hardware.firmware = [
        (pkgs.runCommandLocal "mt7927-bt-firmware-path-fix" { } ''
          fw=${inputs.mt7927.packages.${pkgs.stdenv.hostPlatform.system}.firmware}
          mkdir -p "$out/lib/firmware/mediatek/mt7927"
          cp "$fw/lib/firmware/mediatek/mt6639/BT_RAM_CODE_MT6639_2_1_hdr.bin" \
            "$out/lib/firmware/mediatek/mt7927/BT_RAM_CODE_MT6639_2_1_hdr.bin"
        '')
      ];
    };
}
