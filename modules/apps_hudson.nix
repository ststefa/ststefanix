{ pkgs, ... }: {

  # host-specific apps that will be merged with other declared apps

  environment.systemPackages = with pkgs; [
  ];

  homebrew = {

    masApps = {
    };

    brews = [
      "lxd" # CLI for lxd, https://ubuntu.com/lxd
    ];

    casks = [
      {
        name = "audacity";
        greedy = true;
      }
      {
        name = "blender";
        greedy = true;
      }
      {
        name = "calibre";
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
      {
        name = "freecad";
        greedy = true;
      }
      {
        name = "handbrake";
        greedy = true;
      }
      {
        name = "openscad";
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
        name = "shotcut";
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
        name = "transmission";
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
        name = "xquartz";
        greedy = true;
      }
      {
        name = "zoom";
        greedy = true;
      }
    ];
  };
}
