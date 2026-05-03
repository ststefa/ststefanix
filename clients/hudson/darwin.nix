{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    doxygen # required to build gr-osmosdr
    esptool
    hcloud
  ];

  homebrew = {
    masApps = {
      "AusweisApp" = 948660805;
      "BitPay" = 1440200291;
      "Bitcoin Expert" = 1237809495;
      "djay Pro" = 450527929;
      "GarageBand" = 682658836;
      "iMovie" = 408981434;
      "Telefon" = 406825478;
    };

    brews = [
      "arduino-cli"
      "deno" # Secure runtime for JavaScript
      "ghostscript"
      "glib"
      "gnuradio"
      "hackrf"
      "jpeg-turbo"
      "lxc" # Client for lxc
      "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu"
      "messense/macos-cross-toolchains/aarch64-unknown-linux-musl"
      "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
      "messense/macos-cross-toolchains/x86_64-unknown-linux-musl"
      "messense/macos-cross-toolchains/arm-unknown-linux-gnueabihf"
      "minicom"
      "nss" # Libraries for security-enabled client and server applications
      "openexr" # High dynamic-range image file format
      "openjph" # Open-source implementation of JPEG2000 Part-15
      "pybind11" #
      "pygobject3" #
      "soapyhackrf"
      "soapyrtlsdr"
      "soapysdr"
    ];

    casks = [
      { name = "arduino-ide"; greedy = true; }
      { name = "audacity"; greedy = true; }
      { name = "blender"; greedy = true; }
      { name = "calibre"; greedy = true; }
      { name = "dymo-connect"; greedy = true; }
      { name = "google-chrome"; greedy = true; }
      { name = "gqrx"; greedy = true; }
      { name = "element"; greedy = true; }
      { name = "elgato-camera-hub"; greedy = true; }
      { name = "elgato-stream-deck"; greedy = true; }
      { name = "freecad"; greedy = true; }
      { name = "gather"; greedy = true; }
      { name = "gimp"; greedy = true; }
      { name = "handbrake-app"; greedy = true; }
      { name = "hookmark"; greedy = true; }
      { name = "kicad"; greedy = true; }
      { name = "libreoffice"; greedy = true; }
      { name = "obs"; greedy = true; }
      { name = "openscad"; greedy = true; }
      { name = "orcaslicer"; greedy = true; }
      { name = "powerphotos"; greedy = true; }
      { name = "puppetlabs/puppet/pdk"; greedy = true; }
      { name = "shotcut"; greedy = true; }
      { name = "signal"; greedy = true; }
      { name = "snapmaker-luban"; greedy = true; }
      { name = "subler"; greedy = true; }
      { name = "tor-browser"; greedy = true; }
      { name = "homebrew/cask/transmission"; greedy = true; }
      { name = "tunnelblick"; greedy = true; }
      { name = "veracrypt"; greedy = true; }
      #{ name = "vivaldi"; greedy = true; } # Removed because nix-installed Browsers have problems with local-network permissions (because the executable location changes). Using AppStore Browser instead
      { name = "xquartz"; greedy = true; }
      { name = "zoom"; greedy = true; }
    ];
  };
}
