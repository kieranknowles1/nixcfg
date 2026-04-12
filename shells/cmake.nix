{
  cmake,
  clang,
  gdb,
  flake,
  # Bring our own CC, I prefer clang to gcc
  mkShellNoCC,
  # Target name, for scripts to use
  name ? "unknown",
  # Build directory
  buildDir ? "build",
  # Additional libraries and tools to include
  packages ? [],
  # Key-value options to pass to CMake configure
  options ? {},
  # Additional environment variables
  env ? {},
}: let
  opts = builtins.concatStringsSep " " (map (name: "-D${name}=${options.${name}}") (builtins.attrNames options));

  checkleak' = flake.checkleak.override {
    target = name;
  };
in
  flake.lib.shell.mkShellEx mkShellNoCC ({
      name = "cmake-${name}";

      packages =
        [
          cmake
          clang
          gdb
          checkleak'
        ]
        ++ packages;

      shellHook = ''
        # mkcd into build if not already
        if [[ "$PWD" != *${buildDir} ]]; then
          mkdir -p "${buildDir}"
          cd "${buildDir}"
        fi

        cmake .. ${opts}
        code ..
        cd ..
      '';
    }
    // env)
