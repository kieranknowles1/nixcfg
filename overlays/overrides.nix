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

  # Use the same version of ffmpeg as Immich
  copyparty = prev.copyparty.override {
    ffmpeg = final.jellyfin-ffmpeg;
  };

  # My fork of OpenMW
  openmw = prev.openmw.overrideAttrs (_oldAttrs: {
      src = inputs.src-openmw;
    });
}
