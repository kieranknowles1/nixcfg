{
  lib,
  ...
}: {
  options.custom = {
    editor = lib.mkOption {
      description = "Text editor to use";
      type = lib.types.enum ["vscode"];
      default = "vscode";
    };
  };

  # TODO: This option is here as I'd like to try neovim
  imports = [
    ./vscode
  ];
}
