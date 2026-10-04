# OS-level Windows package baseline.

{ pkgs, ... }:
{
  # Windows-only nix packages. See nix/apps.nix for common packages
  environment.systemPackages = with pkgs; [
  ];
}
