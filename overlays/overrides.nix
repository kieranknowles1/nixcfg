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
  in
    devPkg.overrideAttrs (_oldAttrs: {
      src = inputs.src-openmw;
    });
}
