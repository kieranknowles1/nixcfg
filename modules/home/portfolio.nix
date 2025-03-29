{
  config = {
    # TODO: This is just a placeholder until running NixOS on a server
    # See also: [[packages/portfolio]]
    sops.secrets = {
      "portfolio/cfzone".key = "cloudflare/zoneid";
      "portfolio/cfclearcache".key = "cloudflare/clearcachetoken";
    };
  };
}
