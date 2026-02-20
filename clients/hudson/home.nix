{ ... }:
{
  home.sessionVariables = {
    # Required for gnuradio dialogs to find glib schemas
    GSETTINGS_SCHEMA_DIR = "/opt/homebrew/share/glib-2.0/schemas";
  };

  home.file = {
    "bin/nex_exchange.sh".source = ../../home/files/client/hudson/bin/nex_exchange.sh;
    "bin/nex_price.sh".source = ../../home/files/client/hudson/bin/nex_price.sh;
    "bin/nex_show-order.sh".source = ../../home/files/client/hudson/bin/nex_show-order.sh;
    "bin/ss_cancel.sh".source = ../../home/files/client/hudson/bin/ss_cancel.sh;
    "bin/ss_check.sh".source = ../../home/files/client/hudson/bin/ss_check.sh;
    "bin/ss_info.sh".source = ../../home/files/client/hudson/bin/ss_info.sh;
    "bin/ss_shift.sh".source = ../../home/files/client/hudson/bin/ss_shift.sh;
  };
}
