{ pkgs, ... }: {

  # host-specific apps that will be merged with other declared apps

  environment.systemPackages = with pkgs; [
  ];

  homebrew = {

    masApps = {
    };

    brews = [
      "openshift-cli"
    ];

    casks = [
      { # Enable AWS session manager connections
        name = "session-manager-plugin";
        greedy = true;
      }
      { # Used as distinct browser for annoying kubectl OIDC plugin login process
        name = "vivaldi";
        greedy = true;
      }
    ];
  };
}
