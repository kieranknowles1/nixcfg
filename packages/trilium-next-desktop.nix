{
  trilium-desktop,
  unzip,
}:
trilium-desktop.overrideAttrs (oldAttrs: rec {
  # TODO: Run this on a server
  version = "0.90.12";
  src = builtins.fetchurl {
    url = "https://github.com/TriliumNext/Notes/releases/download/v${version}/TriliumNextNotes-v${version}-linux-x64.zip";
    sha256 = "sha256:0ji28l60wyzhjbi6g5845dnm763bvg7535zfgzcmfgwjs6zr6nfq";
  };
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [unzip];
})
