{
  config,
  lib,
  username,
  useremail,
  ...
}: {
  programs.delta = {
    enable = true;
    options = {
      features = "side-by-side";
    };
  };

  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "*~"
      ".DS_Store"
    ];

    includes = [
      {
        # Tweak git with the (manually supplied) .gitconfig for all repos below dbdksar.
        # This can be replicated for any other such repo collection and is
        # usually applicable to work projects, mostly in order to use a
        # work-specific email+user for commits.
        path = "${config.home.homeDirectory}/workspace/dbdksar/.gitconfig";
        condition = "gitdir:${config.home.homeDirectory}/workspace/dbdksar/**";
      }
    ];

    settings = {
      user={
        name = username;
        email = useremail;
      };
      # System level is taken by global config
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = "merges";
      pull.ff = "only";
      alias = {
        alias = "!git config --get-regexp ^alias\\.";
        brh = "branch";
        cht = "checkout";
        cle = "clone";
        cot = "commit";
        feh = "fetch";
        mee = "merge";
        puh = "push";
        pul = "pull";
        ree = "rebase";
        sth = "stash";
        sts = "status";
      };
    };

    signing = {
      # Default behaviour since 2026-03
      format = null;
      #key = "xxx";
      #signByDefault = true;
    };
  };
}
