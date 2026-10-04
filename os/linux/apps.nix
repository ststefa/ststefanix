# OS-level Linux package baseline.

{ pkgs, ... }:
{
  # Linux-only nix packages. See nix/apps.nix for common packages
  environment.systemPackages = with pkgs; [
    btop
    fd
    inotify-tools
    neovim
  ];
}
