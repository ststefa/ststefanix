{ ... }:
{
  home.file = {
    ".hammerspoon".source = ./files/os/darwin/.hammerspoon;
    ".hammerspoon".recursive = true;

    "bin/switch_windows.swift".source = ./files/os/darwin/bin/switch_windows.swift;
    "bin/loadkeys.sh".source = ./files/os/darwin/bin/loadkeys.sh;
  };
}
