{ inputs, ... }:
{
  flake.homeModules.zshzebra =
    { pkgs, ... }:
    {
      home = {
        username = "zshzebra";
        homeDirectory = "/home/zshzebra";
        stateVersion = "25.11";

        packages = with pkgs; [
          (withNvidiaOffload prismlauncher)
          (withNvidiaOffload blender)
          inputs.temporary-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
      };

      xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

      programs = {
        home-manager.enable = true;

        git = {
          enable = true;
          settings = {
            user.name = "zshzebra";
            user.email = "ryder@retzlaff.family";
            credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
          };
        };

        helix = {
          enable = true;
          settings = {
            theme = "catppuccin_mocha";
            editor.cursor-shape = {
              normal = "block";
              insert = "bar";
            };
          };
          languages.language = [
            {
              name = "nix";
              auto-format = true;
              formatter.command = "${pkgs.nixfmt}/bin/nixfmt";
            }
          ];
        };

        fish.enable = true;

        yazi = {
          enable = true;
          shellWrapperName = "y";
        };

        zoxide = {
          enable = true;
          enableFishIntegration = true;
          options = [ "--cmd cd" ];
        };

        zed-editor = {
          enable = true;
          extensions = [
            "catppuccin"
            "nix"
          ];
          userSettings = {
            theme = {
              mode = "dark";
              dark = "Catppuccin Mocha";
            };
          };
        };

        ghostty = {
          enable = true;

          enableBashIntegration = true;
          enableFishIntegration = true;

          settings = {
            theme = "Catppuccin Mocha";
          };
        };
      };
    };
}
