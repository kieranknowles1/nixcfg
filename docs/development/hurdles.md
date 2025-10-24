# Common Hurdles

A list of common hurdles encountered during development, and how they were
overcome.

## Hardened Services Unable to Write to Disk

Nixpkgs hardens many of its systemd services by default, which can block them
from making legitimate changes to the files system. To overcome this, you can
loosen certain restrictions in their module.

```nix
systemd.services.<service-name>.serviceConfig = {
  # Dynamic users can't properly own files outside of /var, but we want
  # to store data elsewhere where it can be backed up easily
  DynamicUser = lib.mkForce false;
  User = "service-name";
  Group = "service-name";

  # Allow the service to write to its own directory when ProtectSystem=strict,
  # while keeping other paths read-only
  ReadWritePaths = [ cfg.dataDir ];
};

# While we're at it, automate the creation of a data directory
custom.mkdir.${cfg.dataDir} = {
  user = "service-name";
  group = "service-name";
};

users.groups.<service-name> = {};
users.users.<service-name> = {
  isSystemUser = true;
  group = "service-name";
};
```
