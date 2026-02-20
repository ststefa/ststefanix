{
  lib,
  os,
  client,
  username,
  ...
}:
let
  inherit (builtins) pathExists map readFile concatStringsSep;
  osSudoersFragment = ../os + "/${os}/files/etc/sudoers";
  clientSudoersFragment = ../clients + "/${client}/files/etc/sudoers";
  sudoersFragments = lib.filter pathExists [
    osSudoersFragment
    clientSudoersFragment
  ];
in
lib.optionalAttrs (sudoersFragments != [ ]) {
  # Assemble sudoers from OS base and optional client-specific parts
  environment.etc."sudoers.d/nix-${username}".text =
    concatStringsSep "\n" (map readFile sudoersFragments);
}
