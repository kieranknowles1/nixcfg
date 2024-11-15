{
  trilium-desktop,
  unzip,
}:
trilium-desktop.overrideAttrs (oldAttrs: rec {
  # TODO: Run this on a server
  version = "0.90.11-beta";
  src = builtins.fetchurl {
    url = "https://github.com/TriliumNext/Notes/releases/download/v${version}/TriliumNextNotes-v${version}-linux-x64.zip";
    sha256 = "sha256:0cijj3nc67saiydh1mqafp6y8fljkhwxyqjhzfiyg7275244sfng";
  };
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [unzip];
})
