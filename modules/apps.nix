{ pkgs, ... }: {

  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  ##########################################################################

  # Install packages from nix's official package repository.
  #
  # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
  # But on macOS, it's less stable than homebrew.
  #
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    #bash # somehow not reuqired
    #caddy # golang config server
    #docker # does not include docker daemon
    #k3s
    #kcl-cli # kcl-lsp not available, so using brew for all kcl
    #mqttx # not available for aarch64-darwin #dbcicd
    #openlens # not available for aarch64-darwin
    #python311Packages.rstcheck # python3.11-rstcheck-core-1.0.3.drv tests fail
    #python312
    #python312Packages.pip
    #rstcheck # python3.11-rstcheck-core-1.0.3.drv tests fail
    argocd
    argocd-autopilot
    azure-cli
    bc
    coreutils
    cowsay
    curl
    darwin.trash
    delve # go debugger #dbcicd
    diffutils
    docutils
    earthly #dbcicd
    file
    fswatch
    fzf
    gawk
    git
    glow # markdown previewer in terminal
    gnupg
    gnused
    gnutar
    go #dbcicd
    go-task #dbcicd
    golangci-lint #dbcicd
    golangci-lint-langserver #dbcicd
    jfrog-cli #dbcicd
    jq
    just
    k3d
    k9s
    krew
    kubectl
    kubelogin-oidc #dbcicd
    kubernetes-helm
    kubeval #dbcicd #misses important errors
    kustomize
    lefthook #dbcicd
    less
    lsof
    mas
    nats-top #dbcicd
    natscli #dbcicd
    nixd # nix language server, used by vscode nix plugin
    nmap
    nnn # terminal file manager
    nodejs
    opentofu
    pipx
    pre-commit #dbcicd
    pstree
    python311
    python311Packages.docutils
    python311Packages.pip
    python311Packages.pytest
    python311Packages.restructuredtext-lint
    python311Packages.sphinx
    python311Packages.virtualenv
    ripgrep
    sipcalc
    socat
    sops
    sphinx
    stern
    tcpdump
    terraform
    tldr
    tree
    unixtools.nettools
    unixtools.procps
    unzip
    vendir
    vscode
    watchexec
    which
    xz
    yq
    zip
    zstd
  ];

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # runs an brew update on any darwin-rebuild. Too slow.
      # 'zap': uninstalls all formulae(and related files) not listed here.
      #cleanup = "zap";
      # I need to keep surplus formulae for now (i.e., until a way is found to handle formulae device-secific)
      cleanup = "none";
      upgrade = true;
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      #Xcode = 497799835;
      # Wechat = 836500024;
      # NeteaseCloudMusic = 944848654;
      # QQ = 451108668;
      # WeCom = 1189898970;  # Wechat for Work
      # TecentMetting = 1484048379;
      # QQMusic = 595615424;

      "Affinity Designer 2" = 1616831348;
      "Affinity Photo 2" = 1616822987;
      "Affinity Publisher 2" = 1606941598;
      "ColorSlurp" = 1287239339;
      "Consent-O-Matic" = 1606897889;
      "Core Tunnel" = 1354318707;
      "EasyFind" = 411673888;
      "Free Ruler" = 1483172210;
      "Gapplin" = 768053424;
      "HazeOver" = 430798174;
      "Luminar Neo - AI Foto-Editor" = 1584373150;
      "Meeter" = 1510445899;
      "Microsoft Remote Desktop" = 1295203466;
      "Msg Viewer Pro" = 1019539949;
      "OCRKit" = 410309628;
      "Strongbox" = 897283731;
      "WiFi Explorer" = 494803304;
      "WiFi Signal" = 525912054;
      "Xcode" = 497799835;

    };

    taps = [
      "homebrew/services"
      "kcl-lang/tap"
    ];

    # `brew install`
    brews = [
      #"wget" # download tool
      #"curl" # no not install curl via nixpkgs, it's not working well on macOS!
      #"aria2" # download tool
      #"httpie" # http client

      # ststefa
      "docker" # cli part of docker. Try using nix app?
      "imagemagick" # maybe switch to nix pkg
      "openjdl@21" # To activate: sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
      #"iproute2mac" # requires python but that is handled by nix
      "kcl"
      "kcl-lsp"
      "mpdecimal"
      #"mqttx-cli"
      #"openssl@3"
      #"python@3.12" # handled by nix
      #"readline"
      "sqlite"
    ];

    #caskArgs = { # Error: "The option `homebrew.caskArgs.greedy' does not exist."
    #  greedy = true;
    #};

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      #"firefox"
      #"google-chrome"
      #"visual-studio-code"

      # IM & audio & remote desktop & meeting
      #"telegram"
      #"discord"

      #"anki"
      #"iina" # video player
      #"raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      #"stats" # beautiful system monitor
      #"eudic" # 欧路词典

      # Development
      #"insomnia" # REST client
      {
        name = "aldente";
        greedy = true;
      }
      {
        name = "apparency";
        greedy = true;
      }
      {
        name = "bartender";
        greedy = true;
      }
      {
        name = "betterdisplay";
        greedy = true;
      }
      {
        name = "betterzip";
        greedy = true;
      }
      {
        name = "choosy";
        greedy = true;
      }
      {
        name = "chromium";
        greedy = true;
      }
      {
        name = "db-browser-for-sqlite";
        greedy = true;
      }
      {
        name = "deepl";
        greedy = true;
      }
      {
        name = "docker";
        greedy = true;
      }
      {
        name = "element";
        greedy = true;
      }
      # Only hudson
      #{
      #  name = "elgato-camera-hub";
      #  greedy = true;
      #}
      {
        name = "elgato-control-center";
        greedy = true;
      }
      # Only hudson
      #{
      #  name = "elgato-stream-deck";
      #  greedy = true;
      #}
      {
        name = "evernote";
        greedy = true;
      }
      {
        name = "figma";
        greedy = true;
      }
      {
        name = "gather";
        greedy = true;
      }
      {
        name = "gimp";
        greedy = true;
      }
      {
        name = "hammerspoon";
        greedy = true;
      }
      {
        name = "istat-menus";
        greedy = true;
      }
      {
        name = "iterm2";
        greedy = true;
      }
      {
        name = "launchcontrol";
        greedy = true;
      }
      {
        name = "little-snitch";
        greedy = true;
      }
      {
        name = "macfuse";
        greedy = true;
      }
      #{
      #  name = "miro";
      #  greedy = true;
      #}
      {
        name = "mqttx";
        greedy = true;
      }
      {
        name = "obsidian";
        greedy = true;
      }
      {
        name = "openlens";
        greedy = true;
      }
      {
        name = "paletro";
        greedy = true;
      }
      {
        name = "qlmarkdown";
        greedy = true;
      }
      {
        name = "qlstephen";
        greedy = true;
      }
      {
        name = "quicklook-csv";
        greedy = true;
      }
      {
        name = "quicklook-json";
        greedy = true;
      }
      # Required for AWS session manager
      {
        name = "session-manager-plugin";
        greedy = true;
      }
      {
        name = "sf-symbols";
        greedy = true;
      }
      {
        name = "signal";
        greedy = true;
      }
      #{
      #  name = "slack";
      #  greedy = true;
      #}
      #{
      #  name = "snapmaker-luban";
      #  greedy = true;
      #}
      {
        name = "spotify";
        greedy = true;
      }
      {
        name = "suspicious-package";
        greedy = true;
      }
      {
        name = "telegram";
        greedy = true;
      }
      #{
      #  name = "tor-browser";
      #  greedy = true;
      #}
      {
        name = "transmit";
        greedy = true;
      }
      #{
      #  name = "tunnelblick";
      #  greedy = true;
      #}
      {
        name = "unison";
        greedy = true;
      }
      {
        name = "veracrypt";
        greedy = true;
      }
      {
        name = "vivaldi"; # dbcicd, used as distinct browser for annoying OAUTH process
        greedy = true;
      }
      {
        name = "vlc";
        greedy = true;
      }
      {
        name = "wireshark";
        greedy = true;
      }
      #{
      #  name = "zoom";
      #  greedy = true;
      #}
    ];
  };
}
