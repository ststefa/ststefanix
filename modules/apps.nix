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
    nixd # ni language server, used by vscode nix plugin
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
      autoUpdate = false; # runs an brew update on any darwin-rebuild. Too slow.
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
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
      "Consent-O-Matic" = 1606897889;
      "EasyFind" = 411673888;
      "Free Ruler" = 1483172210;
      "Gapplin" = 768053424;
      "HazeOver" = 430798174;
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
      #"openssl@3"
      "sqlite"
      #"iproute2mac" # requires python but that is handled by nix
      "mpdecimal"
      #"python@3.12" # handled by nix
      #"xz"
      "kcl"
      "kcl-lsp"
      #"mqttx-cli"
      #"readline"
    ];

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

      "aldente"
      "bartender"
      "choosy"
      "deepl"
      "docker"
      "element"
      "elgato-control-center"
      "evernote"
      "hammerspoon"
      "istat-menus"
      "iterm2"
      "launchcontrol"
      "little-snitch"
      "obsidian"
      "openlens"
      "paletro"
      "signal"
      "telegram"
      "transmit"
      "wifi-explorer"
      "wireshark"
    ];
  };
}
