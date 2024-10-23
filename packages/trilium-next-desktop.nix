{
  trilium-desktop,
  unzip
}: trilium-desktop.overrideAttrs (oldAttrs: rec {
  # TODO: Run this on a server
  version = "0.90.8";
  src = builtins.fetchurl {
    url = "https://github.com/TriliumNext/Notes/releases/download/v${version}/TriliumNextNotes-v${version}-linux-x64.zip";
    sha256 = "sha256:0l9a2l79jcbr4522k03bbzli9gv96pr15cyig6fg9qpf71cjvda1";
  };
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ unzip ];
})
