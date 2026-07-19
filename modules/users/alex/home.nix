{ ... }:
{
  flake.homeModules.alex =
    { pkgs, ... }:
    {
      home = {
        username = "alex";
        homeDirectory = "/home/alex";
        stateVersion = "25.11";

        packages = with pkgs; [
          temporaryNix
          devenv
        ];

        sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
      };

      xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

      programs = {
        home-manager.enable = true;

        google-chrome.enable = true;

        git = {
          enable = true;
          settings = {
            user.name = "alex";
            user.email = "alex@unifyventures.vc";
            credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
          };
        };

        helix = {
          enable = true;
          settings = {
            theme = "catppuccin_latte";
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

        zsh.enable = true;

        yazi = {
          enable = true;
          shellWrapperName = "y";
        };

        zoxide = {
          enable = true;
          enableFishIntegration = true;
          options = [ "--cmd cd" ];
        };

        ghostty = {
          enable = true;

          enableBashIntegration = true;
          enableZshIntegration = true;

          settings = {
            theme = "Catppuccin Latte";
          };
        };

        vesktop.enable = true;

        gnome-shell = {
          enable = true;
          extensions = [ { package = pkgs.gnomeExtensions.gsconnect; } ];
        };
      };
    };
}
