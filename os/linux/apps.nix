# OS-level Linux package baseline.

{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    fd
    inotify-tools
    neovim
  ];
}
