{ username, useremail,  hostname, ... }:

{
  home = {
    # see ´files_all.nix` for doc
    file = {
      #".config/pushover.conf".source = ./files/hudson/.config/pushover.conf;
    };
  };
}
