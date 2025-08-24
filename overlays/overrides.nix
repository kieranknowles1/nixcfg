{inputs}:
# Overrides to the default nixpkgs
final: prev: {
  xfce = prev.xfce.overrideScope (_nfinal: nprev: {
    thunar = final.symlinkJoin {
      name = "thunar-without-extras";
      paths = [nprev.thunar];
      postBuild = ''
        # Remove the .desktop files for bulk rename and settings to reduce clutter
        rm $out/share/applications/thunar-bulk-rename.desktop
        rm $out/share/applications/thunar-settings.desktop
      '';
    };
  });

  # My fork of OpenMW
  openmw = let
    devPkg = inputs.openmw.packages.${final.system}.openmw-dev;
    is049 = prev.openmw.version != "0.48.0";
  in
    if is049
    then builtins.throw "OpenMW has been updated on nixpkgs, openmw-nix should no longer be needed"
    else
      devPkg.overrideAttrs (_oldAttrs: {
        src = inputs.src-openmw;
      });

  homepage-dashboard =
    if prev.homepage-dashboard.version == "1.3.2"
    then
      prev.homepage-dashboard.overrideAttrs (_oldAttrs: rec {
        version = "1.4.3";
        src = final.fetchFromGitHub {
          owner = "gethomepage";
          repo = "homepage";
          tag = "v${version}";
          hash = "sha256-ib2sErgz1FPnHxmUE8LD/tD1smNcOc0/Ljncl+E9YdM=";
        };

        patches = final.lib.singleton (final.fetchurl {
          url = "https://raw.githubusercontent.com/jnsgruk/nixpkgs/520f14f89c89a02f85058c34044109add55019c3/pkgs/by-name/ho/homepage-dashboard/prerender_cache_path.patch";
          hash = "sha256-i2XeQ13WlfCm+3jIu1huC82R44xQdSS5HFusQX2Ngsg=";
        });

        pnpmDeps = final.pnpm_10.fetchDeps {
          inherit
            (prev.homepage-dashboard)
            pname
            ;
          inherit src version patches;
          fetcherVersion = 1;
          hash = "sha256-IYmAl4eHR0jVpQJfxQRlOBTIbrrjS+dnJpUsl8ee6y4=";
        };
      })
    else builtins.throw "Homepage-dashboard has been updated on nixpkgs, override no longer needed";
}
