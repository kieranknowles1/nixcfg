{inputs}:
# Overrides to the default nixpkgs
final: prev: {
  xfce = prev.xfce.overrideScope (_nfinal: nprev: {
    thunar = let
      withPlugins = nprev.thunar.override {
        thunarPlugins = [prev.xfce.thunar-archive-plugin];
      };
    in
      final.symlinkJoin {
        name = "thunar-without-extras";
        paths = [withPlugins];
        postBuild = ''
          # Remove the .desktop files for bulk rename and settings to reduce clutter
          rm $out/share/applications/thunar-bulk-rename.desktop
          rm $out/share/applications/thunar-settings.desktop
        '';
      };
  });

  networkmanager = prev.networkmanager.override {
    # I don't need openconnect VPN support, and
    # having it brings in GTK as a dependency for my server
    # via openconnect -> stoken -> gtk
    # stoken can be built without GTK, but I'd rather remove it
    # at the source.
    openconnect = null;
  };

  # My fork of OpenMW
  openmw = let
    latestSrc = final.fetchFromGitLab {
      owner = "kieranjohn1";
      repo = "openmw";
      rev = "37104fb6b5bcac976c91bde7c80d27506ca78851";
      hash = "sha256-Ctf1rtbc4Vre+ugf8vZYaLyukcBc2QFP581e9/L8duY=";
    };

    devPkg = inputs.openmw.packages.${final.system}.openmw-dev;
  in
    devPkg.overrideAttrs (_oldAttrs: {
      src = latestSrc;
    });

  # Continuation of Trilium
  # TODO: Use nixpkgs trilium-next once it's up to date
  trilium-desktop = prev.trilium-desktop.overrideAttrs (oldAttrs: rec {
    # TODO: Run this on a server
    version = "0.91.6";
    src = builtins.fetchurl {
      url = "https://github.com/TriliumNext/Notes/releases/download/v${version}/TriliumNextNotes-v${version}-linux-x64.zip";
      sha256 = "sha256:13r9akfakmrpvnyab182irhraf9hpqb24205r8rxjfgj8dpmfa4p";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [final.unzip];
  });
}
