{
  pkgs,
  lib,
  cores,
  username,
  hostname,
  os,
  ...
}:

{
  networking.hostName = hostname;
  networking.fqdn = hostname;

  users.users."${username}" = {
    home = if os == "darwin" then "/Users/${username}" else "/home/${username}";
    description = username;
  };

  nix.package = pkgs.nix;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 30d";
  };

  nix.settings = {
    # Disable auto-optimise-store because of this issue:
    #   https://github.com/NixOS/nix/issues/7273
    # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
    auto-optimise-store = false;

    # Set build core explicitly because some tools use it to calculate parallelism
    cores = cores;

    # enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    trusted-users = [ username ];
  };

  # Blanket permission for unfree packages
  #nixpkgs.config.allowUnfree = true;
  # Allow packages explicitly instead of blanket permission
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "terraform"
      "vault"
    ];

}
// lib.optionalAttrs (os == "darwin") {
  networking.computerName = hostname;
  networking.localHostName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}
