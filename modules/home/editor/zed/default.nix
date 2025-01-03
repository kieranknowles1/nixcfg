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
  };

  config = let
    cfg = config.custom.editor.zed;
  in
    lib.mkIf cfg.enable {
      assertions = lib.singleton {
        assertion = hostConfig.custom.features.desktop;
        message = "Zed requires a desktop environment.";
      };

      programs.zed-editor = {
        enable = true;
        extraPackages = with pkgs; [
          # Language servers
          nixd

          php
          phpactor

          # Universal formatter
          self.formatter.${pkgs.system}
        ];
      };

      # As normal, use our own activate-mutable so we can edit config in place
      custom.mutable.file = let
        # TODO: Share this snippet with VSCode
        files = [
          "settings.json"
          "keymap.json"
        ];
        mkFile = file: {
          name = "${config.xdg.configHome}/zed/${file}";
          value = {
            source = ./${file};
            repoPath = "modules/home/editor/zed/${file}";
          };
        };
      in
        builtins.listToAttrs (map mkFile files);
    };
}
