{ pkgs, ... }@args:
{

  ##########################################################################
  #
  #  Systemwide (config) files
  #
  ##########################################################################

  # Generate a file containing installed packages
  # Generates a separate file for every invocation which will be removed as part of nix gc
  # find and compare them using `ls -l /nix/store/*nix-packages`
  environment.etc."nix-packages".text =
    let
      packages = builtins.map (p: "${p.name}") args.config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
    formatted;

  environment.etc."sudoers.d/ststefa".source = ./files/etc/sudoers.d/ststefa;

}
