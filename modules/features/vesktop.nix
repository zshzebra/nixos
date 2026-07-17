{ ... }:
{
  flake.nixosModules.vesktop =
    { ... }:
    {
      # Overlay with a newer electron version, workaround until nixpkgs pr #542528 closes, which is deferred by pr #537831
      nixpkgs.overlays = [
        (final: prev: {
          vesktop =
            (prev.vesktop.override {
              electron_40 = final.electron_42;
            }).overrideAttrs
              (old: {
                preBuild = ''
                  substituteInPlace package.json \
                    --replace-fail '"electron": "^40.' '"electron": "^42.'
                ''
                + old.preBuild;
              });
        })
      ];
    };
}
