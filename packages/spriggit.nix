{
  stdenv,
  fetchzip,
  lib,
}:
# Packaging something with NuGet dependencies is tricky, so just fetch the
# prebuilt binary.
stdenv.mkDerivation rec {
  pname = "spriggit";
  version = "0.35.1";

  src = fetchzip {
    url = "https://github.com/Mutagen-Modding/Spriggit/releases/download/${version}/SpriggitLinuxCLI.zip";
    # NOTE: Nix seems to cache files by hash, even if the URL changes, so we
    # need to temporarily change the hash to force a redownload
    hash = "sha256-k4ypPBDNUf+RydJkIhwmgZvuNVqOejmzmxsEbabXTXE=";
    stripRoot = false; # The archive doesn't have a root directory
  };

  # Bit of a hack to add execute permissions to the binary
  # $src is read-only, so we need to copy to $out first, then chmod
  # Copy everything as the binary relies on other files in the archive
  installPhase = ''
    mkdir -p $out/share/spriggit
    mkdir -p $out/bin
    cp --recursive $src/* $out/share/spriggit

    chmod +x $out/share/spriggit/Spriggit.CLI
    ln --symbolic $out/share/spriggit/Spriggit.CLI $out/bin/Spriggit.CLI
  '';

  meta = with lib; {
    description = "A tool for converting Bethesda plugin files to text and back";

    longDescription = ''
      A tool to convert Bethesda plugin files (Skyrim, Fallout, Starfield) to text
      and back so that they can be effectively stored in Git repositories.

      NOTE: Spriggit fetches libraries at runtime, so it doesn't follow the
      Nix philosophy of reproducibility.
    '';

    homepage = "https://github.com/Mutagen-Modding/Spriggit";

    licence = licenses.gpl3;

    mainProgram = "Spriggit.CLI";
  };
}
