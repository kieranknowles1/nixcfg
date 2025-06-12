{
  self,
  pkgs,
  lib,
  config,
  hostConfig,
  ...
}: {
  options.custom.editor.zed = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    enable = mkEnableOption "Zed";
    desktopFile = mkOption {
      description = "Name of the .desktop file";
      default = "dev.zed.Zed.desktop";
      type = types.str;
      readOnly = true;
    };

    command = mkOption {
      description = "Command to run the editor";
      default = "zeditor";
      type = types.str;
      readOnly = true;
    };
  };

  config = let
    cfg = config.custom.editor.zed;
  in
    lib.mkIf cfg.enable {
      assertions = lib.singleton {
        assertion = hostConfig.custom.features.desktop;
        message = "Zed requires a desktop environment.";
      };

      # Requires writing zed/settings.json, conflicts with activate-mutable
      stylix.targets.zed.enable = false;

      programs.zed-editor = {
        enable = true;
        # Zed will try to download language servers automatically, but will fail
        # as NixOS doesn't like unpatched binaries without extra work.
        extraPackages = with pkgs; [
          nixd # Nix

          phpactor

          taplo # TOML
          neocmakelsp # CMake
          clang-tools # C++

          rust-analyzer

          # Universal formatter
          self.formatter.${pkgs.system}
        ];
      };

      # As normal, use our own activate-mutable so we can edit config in place
      custom.mutable.file = config.custom.mutable.provisionDir {
        baseRepoPath = "modules/home/editor/zed";
        baseSystemPath = "${config.xdg.configHome}/zed";
        files = [
          "settings.json"
          "keymap.json"
        ];
      };
    };
}
