{
  cmake,
  clang,
  gdb,
  flake,
  # Bring our own CC, I prefer clang to gcc
  mkShellNoCC,
  # Best balance between speed and debuggability
  buildType ? "RelWithDebInfo",
  # Additional libraries and tools to include
  libraries ? [],
}:
flake.lib.shell.mkShellEx mkShellNoCC {
  name = "cmake";

  packages =
    [
      cmake
      clang
      gdb
    ]
    ++ libraries;

  CMAKE_FLAGS = "-DCMAKE_BUILD_TYPE=${buildType}";

  shellHook = ''
    # mkcd into build if not already
    if [[ "$PWD" != *build ]]; then
      mkdir -p "build"
      cd "build"
    fi

    cmake ..
    code ..
    cd ..
  '';
}
