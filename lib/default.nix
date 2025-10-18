{
  lib,
  self,
  inputs,
  ...
}: {
  flake.lib = {
    license = lib.licenses.mit;
    docs = import ./docs.nix {inherit lib;};
    host = import ./host.nix {inherit self inputs;};
    shell = import ./shell.nix;
  };
}
