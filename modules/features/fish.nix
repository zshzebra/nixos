{ self, pkgs, ... }:
{
  flake.nixosModules.fish =
    { pkgs, ... }:
    {
      programs.fish.enable = true;
      programs.bash.interactiveShellInit = ''
        if grep -qv fish /proc/$PPID/comm && [[ $SHLVL == [12] ]]; then
          SHELL=${pkgs.fish}/bin/fish exec fish
        fi
      '';
    };
}
