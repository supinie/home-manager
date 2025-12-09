{
  enable = true;
  settings = {
    user = {
      name = "supinie";
      email = "86788874+supinie@users.noreply.github.com";
    };
    alias = {
      staash = "stash --all";
      wdiff = "diff --word-diff";
    };
    push.autoSetupRemote = true;
    init.defaultBranch = "main";
    pull.rebase = true;
  };
  ignores = [
    "*.swp"
    ".direnv/"
  ];
}
