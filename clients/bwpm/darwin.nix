{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    delve
    kubelogin-oidc
    kubeval
    kubevirt
    lzip
    nats-server
    nats-top
    natscli
    pre-commit
  ];

  homebrew = {
    masApps = { };

    brews = [
      "earthly"
      "mkcert"
      "openshift-cli"
      "socket_vmnet"
    ];

    casks = [
      { name = "amazon-workspaces"; greedy = true; }
      { name = "session-manager-plugin"; greedy = true; }
      { name = "vivaldi"; greedy = true; }
    ];
  };
}
