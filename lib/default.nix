{
  lib,
  self,
  inputs,
  ...
}: {
  flake.lib = {
    license = lib.licenses.agpl3Only;
    docs = import ./docs.nix {inherit lib;};
    host = import ./host.nix {inherit self inputs;};
    shell = import ./shell.nix;
  };
}
