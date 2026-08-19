{ self, inputs, ... }:
{
  flake.homeModules.zshzebra =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.obs
        self.homeModules.helium
      ];

      home = {
        username = "zshzebra";
        homeDirectory = "/home/zshzebra";
        stateVersion = "25.11";

        packages = with pkgs; [
          (withNvidiaOffload prismlauncher)
          (withNvidiaOffload blender)
          inputs.temporary-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
          devenv

          gnomeExtensions.gsconnect
          gnomeExtensions.vicinae
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

        mergiraf = {
          enable = true;
          enableGitIntegration = true;
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
          keymap = {
            mgr.prepend_keymap = [
              {
                run = "plugin gitui";
                on = [
                  "g"
                  "i"
                ];
              }
            ];
          };
          plugins = with pkgs.yaziPlugins; {
            gitui.package = gitui;
          };
        };

        gitui = {
          enable = true;
          theme = ''
            (
                selected_tab: Some("Reset"),
                command_fg: Some("#cdd6f4"),
                selection_bg: Some("#585b70"),
                selection_fg: Some("#cdd6f4"),
                cmdbar_bg: Some("#181825"),
                cmdbar_extra_lines_bg: Some("#181825"),
                disabled_fg: Some("#7f849c"),
                diff_line_add: Some("#a6e3a1"),
                diff_line_delete: Some("#f38ba8"),
                diff_file_added: Some("#a6e3a1"),
                diff_file_removed: Some("#eba0ac"),
                diff_file_moved: Some("#cba6f7"),
                diff_file_modified: Some("#fab387"),
                commit_hash: Some("#b4befe"),
                commit_time: Some("#bac2de"),
                commit_author: Some("#74c7ec"),
                danger_fg: Some("#f38ba8"),
                push_gauge_bg: Some("#89b4fa"),
                push_gauge_fg: Some("#1e1e2e"),
                tag_fg: Some("#f5e0dc"),
                branch_fg: Some("#94e2d5")
            )
          '';
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

        nix-index.enable = true;

        vesktop.enable = true;

        vicinae = {
          enable = true;

          settings = {
            theme = {
              dark = {
                name = "catppuccin-mocha";
                icon_theme = "default";
              };
            };
          };

          systemd = {
            enable = true;
            autoStart = true;
          };
        };

        gnome-shell = {
          enable = true;
        };
      };
    };
}
