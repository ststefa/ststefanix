{ pkgs, username, os, ... }:
let
  homeDir = if os == "darwin" then "/Users/${username}" else "/home/${username}";
in
{
  programs.bash.enable = true;
  environment.shells = [ pkgs.bash ];

  environment.variables = {
    EDITOR = "code -g";
    ANSIBLE_NOCOWS = "1";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    KUBE_EDITOR = "code -w";

    HISTTIMEFORMAT = "%F %T ";
    HISTCONTROL = "ignoreboth";
    PROMPT_COMMAND = "history -a";

    GOPATH = "${homeDir}/tech/go";
    GOBIN = "${homeDir}/bin";
    GOTOOLDIR = "${homeDir}/bin";

    SOPS_AGE_KEY_FILE = "${homeDir}/.config/sops/age/keys.txt";

    BAO_ADDR = "https://bao.heldenzeit.net";
    VAULT_ADDR = "https://bao.heldenzeit.net";

    RUFF_CACHE_DIR = "${homeDir}/.cache/ruff";
  };
}
