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
}
