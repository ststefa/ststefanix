{
  lib,
  username,
  useremail,
  ...
}: {
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

    # System level is taken by global config
    #userName = username;
    #userEmail = useremail;
    userName = "ststefa";
    userEmail = "ststefa@heldenzeit.net";

    includes = [
      {
        # use diffrent email & name for work
        path = "~/workspace/dbdksar/.gitconfig";
        condition = "gitdir:~/workspace/dbdksar/";
      }
    ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = "merges";
      pull.ff = "only";
    };

    # signing = {
    #   key = "xxx";
    #   signByDefault = true;
    # };

    delta = {
      enable = true;
      options = {
        features = "side-by-side";
      };
    };

    aliases = {
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
}
