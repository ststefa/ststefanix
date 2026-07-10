{ pkgs, username, os, ... }:
let
  homeDir = if os == "darwin" then "/Users/${username}" else "/home/${username}";
  gemHome = "${homeDir}/.local/share/gem/ruby/4.0.0";
in
{
  programs.bash.enable = true;
  environment.shells = [ pkgs.bash ];

  environment.variables = {
    EDITOR = "code -g";
    KUBE_EDITOR = "code -w";

    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    HISTTIMEFORMAT = "%F %T ";
    HISTCONTROL = "ignoreboth";
    PROMPT_COMMAND = "history -a";

    GEM_HOME = gemHome;
    GEM_PATH = "${gemHome}:/opt/homebrew/lib/ruby/gems/4.0.0:/opt/homebrew/Cellar/ruby/4.0.5/lib/ruby/gems/4.0.0";

    GOPATH = "${homeDir}/tech/go";
    GOBIN = "${homeDir}/bin";
    GOTOOLDIR = "${homeDir}/bin";

    SOPS_AGE_KEY_FILE = "${homeDir}/.config/sops/age/keys.txt";

    BAO_ADDR = "https://bao.heldenzeit.net";
    VAULT_ADDR = "https://bao.heldenzeit.net";

    RUFF_CACHE_DIR = "${homeDir}/.cache/ruff";

    ANSIBLE_NOCOWS = "1";
  };
}
