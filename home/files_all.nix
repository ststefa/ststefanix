{ username, useremail,  hostname, ... }:

{
  home = {
    # Manage files in home dir. They will be symlinked to nix store.
    # Will not be overwritten if they exist. If undeclared, they will be removed.
    file = {
      ".test".text =
      ''
        # ATTENTION, managed by NIX
        Just an xample
      '';

      # Files
      ".ansible.cfg".source = ./files/all/.ansible.cfg;
      ".pypirc".source = ./files/all/.pypirc;
      ".vimrc".source = ./files/all/.vimrc;
      "Library/Application Support/sops/age/keys.txt".source = (./files/all + "/Library/Application Support/sops/age/age_keys.txt");

      # dirs. "recursive" causes links to be created on the deepest level instead of the highest
      ".hammerspoon".source = ./files/all/.hammerspoon; ".hammerspoon".recursive = true;
      ".ssh".source = ./files/all/.ssh; ".ssh".recursive = true;
      "bin".source = ./files/all/bin; "bin".recursive = true;
      "workspace".source = ./files/all/workspace; "workspace".recursive = true;
    };
  };

  # Attempt to iterate over files/all/*
  #mysrc = builtins.filterSource
  #  (path: type: type != "directory" || baseNameOf path != ".svn")
  #  ./test;
}
