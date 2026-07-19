{ inputs, self, ... }:
{
  _module.args.mkHost = import ./_mkhost.nix { inherit inputs self; };
}
