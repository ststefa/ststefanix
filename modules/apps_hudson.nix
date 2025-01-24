{ pkgs, ... }: {

  # host-specific apps that will be merged with other declared apps

  environment.systemPackages = with pkgs; [
    esptool
  ];

  homebrew = {

    masApps = {
      "AusweisApp" = 948660805;
      "BitPay" = 1440200291;
      "Bitcoin Expert" = 1237809495;
      "GarageBand" = 682658836;
      "iMovie" = 408981434;
      "Telefon" = 406825478;
    };

    brews = [
      "aarch64-unknown-linux-gnu" # toolchain for rust cross-compilation
      "arduino-cli"
      "ghostscript"
      "glib"
      "gnuradio"
      "hackrf"
      "jpeg-turbo"
      "lxc" # CLI for lxd, https://ubuntu.com/lxd
      "minicom" # used for serial device access
      "soapyhackrf"
      "soapyrtlsdr"
      "soapysdr"
      "x86_64-unknown-linux-gnu" # toolchain for rust cross-compilation
      "x86_64-unknown-linux-musl" # toolchain for rust cross-compilation

    ];

    casks = [
      {
        name = "arduino-ide";
        greedy = true;
      }
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
        name = "dymo-connect";
        greedy = true;
      }
      {
        name = "google-chrome";
        greedy = true;
      }
      { # SDR GUI App
        name = "gqrx";
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
      { # Pixel collab world
        name = "gather";
        greedy = true;
      }
      {
        name = "gimp";
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
      {
        name = "orcaslicer";
        greedy = true;
      }
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
