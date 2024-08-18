{
  pkgs,
  flake,
}: let
  GL = "GLVND"; # TODO: What does this do?

  # TODO: Do we need this?
  # osgOverride = (pkgs.openscenegraph.override { colladaSupport = true; }).overrideDerivation (old: {

  # });

  # OpenMW requires double precision bullet
  bulletOverride = pkgs.bullet.overrideDerivation (old: {
    cmakeFlags =
      (old.cmakeFlags or [])
      ++ [
        "-Wno-dev" # Suppress warnings intended for Bullet developers
        "-DOpenGL_GL_PREFERENCE=${GL}"
        "-DUSE_DOUBLE_PRECISION=ON"
        "-DBULLET2_MULTITHREADING=ON" # OpenMW can use ths
      ];
  });

  # We need MyGUI 3.4.3, while nixpkgs has 3.4.2
  myguiOverride = pkgs.mygui.overrideDerivation (old: rec {
    version = "3.4.3";
    src = pkgs.fetchFromGitHub {
      owner = "MyGUI";
      repo = "mygui";
      rev = "MyGUI${version}";
      sha256 = "sha256-qif9trHgtWpYiDVXY3cjRsXypjjjgStX8tSWCnXhXlk=";
    };

    # disable-framework.patch can't be applied and was only needed for macOS
    patches = [];
  });
in
  flake.lib.shell.mkShellEx {
    name = "openmw";

    # TODO: Sort package lists

    # Packages to put on our PATH
    packages = with pkgs; [
      cmakeWithGui
      clang
    ];

    # Libraries needed for building
    buildInputs = with pkgs; [
      SDL2
      boost
      bulletOverride
      ffmpeg
      xorg.libXt
      luajit
      lz4
      myguiOverride
      openal
      openscenegraph
      recastnavigation
      unshield
      yaml-cpp
    ];

    # Libraries needed for running
    # TODO: Is this the same in a shell? Will compiled binaries work outside the shell?
    nativeBuildInputs = with pkgs; [
      libsForQt5.qt5.wrapQtAppsHook
      libsForQt5.qt5.qttools
      pkg-config
    ];

    # cd to the build directory if we're not already in the repo
    shellHook = ''
      if ! [[ "$PWD" =~ /openmw$ ]]; then
        cd "$HOME/Documents/src/openmw/build"
      fi
    '';
  }
