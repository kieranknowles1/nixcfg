{
  src-tldr,
  nushell,
  runCommand,
}:
runCommand "tldr-pages.db" { } ''
  ${nushell}/bin/nu ${./buildPages.nu} ${src-tldr} $out
''
# }: let
#   platformPages = plat: "${src-tldr}/pages.${language}/${plat}";
# in
#   runCommand "tldr-pages" {} ''
#     mkdir -p $out
#     # Platform-specific pages take priority
#     # Not using symlinkJoin to avoid including unused pages in the result
#     cp ${platformPages platform}/* $out
#     cp --no-clobber ${platformPages "common"}/* $out
#     cp ${platformPages "common"}/..md $out/
#   ''
