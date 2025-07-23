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
      custom.mutable.file = {
        "${config.xdg.configHome}/zed/settings.json" = {
          repoPath = "modules/home/editor/zed/settings.json";
          source = ./settings.json;
        };
        "${config.xdg.configHome}/zed/keymap.json" = {
          repoPath = "modules/home/editor/zed/keymap.json";
          source = ./keymap.json;
        };
        "${config.xdg.configHome}/zed/snippets" = {
          repoPath = "modules/home/editor/common/snippets";
          source = ../common/snippets;
        };
      };
    };
}
