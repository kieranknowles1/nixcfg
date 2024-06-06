{
  lib,
  ...
}: {
  # TODO: Link hostConfig.development.enable and do something with it
  options = {
    custom.development.editor = lib.mkOption {
      # TODO: Support Neovim
      type = lib.types.enum ["vscode"];
      default = "vscode";
      description = "The IDE to install for development";
    };
  };

  # We need to still import every module, even if we don't use it
  # otherwise we get an infinite recursion error
  imports = [
    ./vscode
  ];
}
