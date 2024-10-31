{ username, useremail,  hostname, ... }:

{
  home = {
    # Manage files in home dir. They will be symlinked to nix store.
    # Will not be overwritten if they exist. If undeclared, they will be removed.
    file = {
      "bin/nex_exchange.sh".source = ./files/hudson/bin/nex_exchange.sh;
      "bin/nex_price.sh".source = ./files/hudson/bin/nex_price.sh;
      "bin/nex_show-order.sh".source = ./files/hudson/bin/nex_show-order.sh;
      "bin/ss_cancel.sh".source = ./files/hudson/bin/ss_cancel.sh;
      "bin/ss_check.sh".source = ./files/hudson/bin/ss_check.sh;
      "bin/ss_info.sh".source = ./files/hudson/bin/ss_info.sh;
      "bin/ss_shift.sh".source = ./files/hudson/bin/ss_shift.sh;
    };
  };
}
