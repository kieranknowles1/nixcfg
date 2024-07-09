{lib, ...}: {
  options.custom = {
    editor = lib.mkOption {
      description = "Text editor to use";
      type = lib.types.enum [
        "vscode"
        "neovim"
      ];
      default = "neovim";
    };
  };

  imports = [
    ./vscode
    ./neovim
  ];
}
