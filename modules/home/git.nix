{config, ...}: {
  config = let
    details = config.custom.userDetails;
  in {
    programs.git = {
      # This is stored in a Git repo, so it wouldn't make sense to have a system without Git
      enable = true;

      userName = details.firstName;
      userEmail = details.email;

      lfs.enable = true;
    };
  };
}
