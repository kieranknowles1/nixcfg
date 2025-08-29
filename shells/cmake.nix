{
  cmake,
  clang,
  gdb,
  flake,
  # Bring our own CC, I prefer clang to gcc
  mkShellNoCC,
  # Target name, for scripts to use
  name ? "unknown",
  # Additional libraries and tools to include
  libraries ? [ ],
  # Key-value options to pass to CMake configure
  options ? { },
}:
let
  opts = builtins.concatStringsSep " " (
    map (name: "-D${name}=${options.${name}}") (builtins.attrNames options)
  );

  checkleak' = flake.checkleak.override {
    target = name;
  };
in
flake.lib.shell.mkShellEx mkShellNoCC {
  name = "cmake-${name}";

  packages = [
    cmake
    clang
    gdb
    checkleak'
  ]
  ++ libraries;

  shellHook = ''
    # mkcd into build if not already
    if [[ "$PWD" != *build ]]; then
      mkdir -p "build"
      cd "build"
    fi

    cmake .. ${opts}
    code ..
    cd ..
  '';
}
