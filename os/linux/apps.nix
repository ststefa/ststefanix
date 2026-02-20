{ pkgs, ... }:
{
  # OS-level Linux package baseline.
  environment.systemPackages = with pkgs; [
    btop
    fd
    inotify-tools
    neovim
  ];
}
