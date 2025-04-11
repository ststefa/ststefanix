{ pkgs, ... }: {

  # host-specific apps that will be merged with other declared apps

  environment.systemPackages = with pkgs; [
    #earthly # need older version, using brew
    delve # go debugger
    kubelogin-oidc # kubectl plugin for OIDC login
    kubeval # misses important errors
    kubevirt # kubevirt cli (virtctl)
    lefthook # git hook setup helper
    lzip # lzma compression used in tzdb
    nats-server # NATS messaging server
    nats-top # NATS messaging perf
    natscli # NATS messaging client
    pre-commit # git precommit helper
  ];

  homebrew = {

    masApps = {
    };

    brews = [
      "earthly"
      "mkcert"
      "openshift-cli"
      "socket_vmnet" # Required for libvirt tests/qemu
    ];

    casks = [
      { name = "amazon-workspaces"; greedy = true; } # Required for HVLE access
      { name = "session-manager-plugin"; greedy = true; } # Enable AWS session manager connections
      { name = "vivaldi"; greedy = true; } # Used as distinct browser for annoying kubectl OIDC plugin login process. Use in conjunction with Choosy.app
    ];
  };
}
