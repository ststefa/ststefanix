{ pkgs, ... }: {

  # host-specific apps that will be merged with other declared apps

  environment.systemPackages = with pkgs; [
  ];

  homebrew = {

    masApps = {
    };

    brews = [
    ];

    casks = [
      {
        name = "audacity";
        greedy = true;
      }
      {
        name = "element";
        greedy = true;
      }
      {
        name = "elgato-camera-hub";
        greedy = true;
      }
      {
        name = "elgato-stream-deck";
        greedy = true;
      }
      #{. Outdated 2024-10-12. Installed from github
      #  name = "orcaslicer";
      #  greedy = true;
      #}
      { # Extended app for Apple Fotos libraries
        name = "powerphotos";
        greedy = true;
      }
      {
        name = "signal";
        greedy = true;
      }
      {
        name = "snapmaker-luban";
        greedy = true;
      }
      {
        name = "spotify";
        greedy = true;
      }
      {
        name = "subler";
        greedy = true;
      }
      {
        name = "tor-browser";
        greedy = true;
      }
      {
        name = "tunnelblick";
        greedy = true;
      }
      {
        name = "veracrypt";
        greedy = true;
      }
      {
        name = "zoom";
        greedy = true;
      }
    ];
  };
}
