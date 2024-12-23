# Overrides to the default nixpkgs
_final: prev: {
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
    # via stoken.
    # stoken can be built without GTK, but I'd rather remove it
    # at the source.
    openconnect = null;
  };
}
