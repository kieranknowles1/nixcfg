{
  lib,
  ...
}: {
  # TODO: Link hostConfig.development.enable and do something with it
  options = {
    custom.development.editor = lib.mkOption {
      type = lib.types.enum [
        "neovim"
        "vscode"
      ];
      default = "neovim";
      description = "The IDE to install for development";
    };
  };

  # We need to still import every module, even if we don't use it
  # otherwise we get an infinite recursion error
  imports = [
    ./neovim
    ./vscode
  ];
}
