{
  config,
  lib,
  pkgs,
  self,
  ...
}: let
  inherit (config.custom) userDetails;

  fixupPackage = {
    package,
    replacements,
    removals,
    name,
  }: let
    script = self.builders.${pkgs.hostPlatform.system}.buildScript {
      runtime = pkgs.python3.withPackages (ps: [ps.pyyaml]);
      name = "fixup-espanso-package";
      src = ./patch-matches.py;
    };
  in
    pkgs.stdenv.mkDerivation {
      name = "espanso-package-${name}";
      src = package;

      FIXUP_CONFIG = builtins.toJSON {
        inherit replacements removals;
      };

      buildPhase = ''
        mkdir -p $out

        # NOTE: This assumes all matches are in a single file. This seems to be the convention
        ${lib.getExe script} "$FIXUP_CONFIG" $src/package.yml $out/package.yml
      '';
    };
in {
  options.custom = let
    inherit (lib) mkOption mkEnableOption types;
  in {
    espanso = {
      enable = mkEnableOption "Espanso";

      packages = lib.mkOption {
        description = ''
          A list of Espanso packages to install.
        '';

        type = types.attrsOf (types.submodule {
          options = {
            url = mkOption {
              description = "URL to a tarball of the package";
              type = types.str;
              example = "https://github.com/espanso/espanso-package/archive/refs/heads/master.tar.gz";
            };
            hash = mkOption {
              description = "SHA256 hash of the package";
              type = types.str;
              default = ""; # Nix will use a placeholder and tell us the correct hash
              example = "sha256-...";
            };
            dir = mkOption {
              description = "If set, use a subdirectory of the package as the source";
              type = types.nullOr types.str;
              default = null;
              example = "package-dir";
            };
            replacements = mkOption {
              description = ''
                String replacements to apply to replacement values, in the form
                original = replacement.
              '';
              type = types.attrsOf types.str;
              default = {};
              example = {
                "a" = "b";
                "c" = "d";
              };
            };
            removals = mkOption {
              description = ''
                Triggers to remove from the package.
              '';
              type = types.listOf types.str;
              default = [];
              example = [":trigger:"];
            };
          };
        });
      };
    };
  };

  config = lib.mkIf config.custom.espanso.enable {
    services.espanso = {
      enable = true;
      # Don't manage configs here, apart from some global variables
      configs = {};
      matches.nix-globals = {
        global_vars = let
          # All variables in Espanso come from one of several sources.
          # We are only interested in constants here, so we use the echo
          # type to define them.
          # This is a helper as the syntax is a bit verbose
          mkGlobalVar = name: value: {
            inherit name;
            type = "echo";
            params.echo = value;
          };
        in [
          (mkGlobalVar "email" userDetails.email)
          (mkGlobalVar "firstname" userDetails.firstName)
          (mkGlobalVar "surname" userDetails.surName)
        ];
      };
    };

    custom.mutable.file = config.custom.mutable.provisionDir {
      baseRepoPath = "modules/home/espanso";
      baseSystemPath = "${config.xdg.configHome}/espanso";
      files = [
        "config/default.yml"
        "config/email.yml"
        "match/_email.yml"
        "match/base.yml"
        "match/spell.yml"
      ];
    };

    xdg.configFile =
      lib.attrsets.mapAttrs' (name: package: {
        name = "espanso-package-${name}";
        value = {
          source = let
            file = builtins.fetchTarball {
              inherit (package) url;
              sha256 = package.hash;
            };

            fullPath = "${file}/${package.dir or ""}";
          in
            fixupPackage {
              inherit name;
              inherit (package) replacements removals;
              package = fullPath;
            };

          target = "espanso/match/packages/${name}";
        };
      })
      config.custom.espanso.packages;
  };
}
