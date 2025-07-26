{
  username,
  hostname,
  pkgs,
  ...
} @ args:
#############################################################
#
#  Host & Users configuration
#
#############################################################
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    description = username;
  };

  nix.settings.trusted-users = [username];
}
