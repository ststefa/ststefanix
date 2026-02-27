{ inventory, ... }:
let
  renderedInventory = builtins.concatStringsSep "\n" (
    builtins.map (k: "${k}: ${toString (builtins.getAttr k inventory)}") (builtins.attrNames inventory)
  );
in

{
  home = {
    # Manage files in home dir. They will be symlinked to nix store.
    # Will not be overwritten if they exist. If undeclared, they will be removed.
    file = {
      # Example for a text file with inline content. Remove if applicable.
      ".nix-inventory".text = ''
        # ATTENTION! Managed by Nix
        These are the properties defined in the nix inventory for this host:
        ${renderedInventory}
      '';


      # Files
      ".ansible.cfg".source = ./files/common/.ansible.cfg;
      ".bash_functions".source = ./files/common/.bash_functions;
      ".curlrc".source = ./files/common/.curlrc;
      ".pypirc".source = ./files/common/.pypirc;
      ".vimrc".source = ./files/common/.vimrc;

      # Directories. "recursive" causes links to be created on the deepest level instead of the highest. This allows to mix dir contents with unmanaged content
      ".cargo".source = ./files/common/.cargo;
      ".cargo".recursive = true;
      ".ssh".source = ./files/common/.ssh;
      ".ssh".recursive = true;
      "bin".source = ./files/common/bin;
      "bin".recursive = true;
      "workspace".source = ./files/common/workspace;
      "workspace".recursive = true;
    };
  };
}
