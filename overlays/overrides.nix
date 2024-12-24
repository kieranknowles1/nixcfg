# Overrides to the default nixpkgs
final: prev: {
  xfce = prev.xfce.overrideScope (_nfinal: nprev: {
    thunar = nprev.thunar.overrideAttrs (oldAttrs: {
      postFixup = ''
        ${oldAttrs.postFixup or ""}
        # Remove the .desktop files for bulk rename and settings to reduce clutter
        rm $out/share/applications/thunar-bulk-rename.desktop
        rm $out/share/applications/thunar-settings.desktop
      '';
    });
  });

  networkmanager = prev.networkmanager.override {
    # I don't need openconnect VPN support, and
    # having it brings in GTK as a dependency for my server
    # via openconnect -> stoken -> gtk
    # stoken can be built without GTK, but I'd rather remove it
    # at the source.
    openconnect = null;
  };

  # Continuation of Trilium, not currently in nixpkgs
  trilium-desktop = prev.trilium-desktop.overrideAttrs (oldAttrs: rec {
    # TODO: Run this on a server
    version = "0.90.12";
    src = builtins.fetchurl {
      url = "https://github.com/TriliumNext/Notes/releases/download/v${version}/TriliumNextNotes-v${version}-linux-x64.zip";
      sha256 = "sha256:0ji28l60wyzhjbi6g5845dnm763bvg7535zfgzcmfgwjs6zr6nfq";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [final.unzip];
  });
}
