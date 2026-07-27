{ ... }:
{
  flake.nixosModules.mcad =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        freecad
      ];

      # Fix until nixpkgs pr #537721 get's merged
      nixpkgs.overlays = [
        (final: prev: {
          pdal = prev.pdal.overrideAttrs (old: rec {
            version = "2.10.0";
            src = prev.fetchFromGitHub {
              owner = "PDAL";
              repo = "PDAL";
              tag = version;
              hash = "sha256-uqWawto3EJJaFhmhQn9eg+4s7NuhmVO5YXC6igkCeU0=";
            };
            disabledTests = (old.disabledTests or [ ]) ++ [
              "pdal_io_copc_remote_reader_test"
            ];
          });

          vtk_9_5 = prev.vtk_9_5.overrideAttrs (old: {
            NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -fpermissive";
          });

          freecad = prev.freecad.overrideAttrs (old: {
            postInstall = ''
              sed -i \
                -e "s|^TryExec=.*freecad-thumbnailer.*|TryExec=$out/bin/freecad-thumbnailer|" \
                -e "s|^Exec=.*freecad-thumbnailer|Exec=$out/bin/freecad-thumbnailer|" \
                $out/share/thumbnailers/FreeCAD.thumbnailer
            '';
          });
        })
      ];
    };
}
