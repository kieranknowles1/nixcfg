# Use-level secrets to be provisioned by SOPS
# These are available in $XDG_RUNTIME_DIR/secrets.d (usually /run/user/$UID/secrets.d)
# as well as $HOME/.config/sops-nix/secrets
{...}: {
  imports = [
    ../shared/secrets.nix
  ];

  # TODO: Remove this once we have some actual secrets
  sops.secrets.test.key = "test";
}
