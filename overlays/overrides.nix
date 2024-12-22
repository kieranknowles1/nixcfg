# Overrides to the default nixpkgs
final: prev: {
  xfce = prev.xfce.overrideScope (nfinal: nprev: {
    thunar = nprev.thunar.overrideAttrs (oldAttrs: {
      postFixup = ''
        ${oldAttrs.postFixup or ""}
        # Remove the .desktop files for bulk rename and settings to reduce clutter
        rm $out/share/applications/thunar-bulk-rename.desktop
        rm $out/share/applications/thunar-settings.desktop
      '';
    });
  });
}
