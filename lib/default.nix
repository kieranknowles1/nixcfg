{
  lib,
  self,
  inputs,
  ...
}: {
  license = lib.licenses.mit;
  attrset = import ./attrset.nix;
  docs = import ./docs.nix {inherit lib inputs;};
  host = import ./host.nix {inherit self inputs;};
  shell = import ./shell.nix;
}
