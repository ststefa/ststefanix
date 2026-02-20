{ lib, ... }:
{
  system.stateVersion = lib.mkDefault "24.05";

  networking.networkmanager.enable = lib.mkDefault true;

  time.timeZone = lib.mkDefault "Europe/Berlin";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
}
