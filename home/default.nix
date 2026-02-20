{
  username,
  hostname,
  useremail,
  client,
  os,
  pkgs,
  ...
}:

{
  imports = [
    ./shell.nix
    ./core.nix
    ./git.nix
    ./starship.nix
    ./files_common.nix
    (./. + "/files_${os}.nix")
    (../os + "/${os}/home.nix")
    (../clients + "/${client}/home.nix")
  ];

  home = {
    username = username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
