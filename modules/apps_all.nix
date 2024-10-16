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
    age
    ansible
    argocd
    argocd-autopilot
    asciinema
    awscli2
    azure-cli
    bat
    bc
    bottom
    #caddy # golang config server
    cmakeMinimal
    colima
    coreutils
    cowsay
    curl
    darwin.iproute2mac
    darwin.trash
    delve # go debugger @dbcicd
    #diffoscope # takes too long to build on update
    diffutils
    #docker # does not include docker daemon
    docutils
    dutree
    earthly # @dbcicd
    esptool
    exiftool
    ffmpeg-headless
    figlet
    file
    findutils # GNU find, locate, updatedb, xargs
    fortune
    fswatch
    fzf
    gawk
    gcc
    git
    git-crypt
    git-agecrypt
    glances # nicer top
    glow # markdown previewer in terminal
    gnugrep
    gnumake
    gnupg
    gnused
    gnutar
    go # @dbcicd
    go-task # @dbcicd
    golangci-lint # @dbcicd
    golangci-lint-langserver # @dbcicd
    gopls # go language server
    hackrf
    htop # Colored top
    imagemagick
    #inotify-tools #No aarch64-apple-darwin
    iperf
    # jdk21_headless # does not provide bin, use temurin instead
    #jfrog-cli # Artifactory cli @dbcicd #Outdated on unstable
    jinja2-cli
    jq
    just
    k3d #not up to date, use cask #using unstable
    #k3s
    k9s
    #kcl-cli # kcl-lsp not available, so using brew for all kcl
    krew
    kubectl
    kubelogin-oidc # kubectl plugin for OIDC login @dbcicd
    kubernetes-helm
    kubeval # @dbcicd #misses important errors
    kubevirt # @dbcicd kubevirt cli (virtctl)
    kustomize
    lefthook # git hook setup helper @dbcicd
    less
    lima
    llvm_18
    lsof
    lzip # lzma compression used in tzdb @dbcicd
    mas # Mac Appstore cli
    minio-client
    #mqttx Not available for aarch64-apple-darwin
    nats-server # NATS messaging server @dbcicd
    nats-top # NATS messaging perf @dbcicd
    natscli # NATS messaging client @dbcicd
    nixd # nix language server, used by vscode nix plugin
    nmap
    #nnn # terminal file manager, replaced by yazi
    nodejs
    oath-toolkit # Provides oathtool
    #openlens # not available for aarch64-darwin
    openshift # openshift "oc" client
    #openssh # sometimes aborts sessions with "package too long" errors, esp. on apume. Using brew.
    opentofu
    parallel
    pdfminer # PDF parser and analyzer
    pipx
    poetry
    pre-commit # git precommit helper @dbcicd
    pstree
    psutils
    pv
    python311
    python311Packages.coverage
    python311Packages.debugpy
    # python311Packages.docutils #build error in unstable
    python311Packages.jsonpatch
    python311Packages.keyring
    python311Packages.pip
    python311Packages.pylint
    python311Packages.pytest
    python311Packages.restructuredtext-lint
    #python311Packages.rstcheck # python3.11-rstcheck-core-1.0.3.drv tests fail
    #python311Packages.sphinx #build error in unstable
    python311Packages.virtualenv
    python311Packages.wheel
    qemu_kvm
    ripgrep
    #rstcheck # python3.11-rstcheck-core-1.0.3.drv tests fail
    ruby
    #ruff # not up to date, use brew
    #rustdesk # not up to date, use brew
    #rustup cleanup on hudson required first
    shellcheck
    sipcalc
    socat
    sops
    sphinx
    sqlite
    stern
    stress-ng
    tcpdump
    temurin-bin-21
    #terraform #Takes too long to build, using brew
    tesseract4
    tflint
    tldr
    tmux
    tree
    unixtools.nettools
    unixtools.procps
    unzip
    upx # Executable file compressor. Nice for golang ;)
    #uv # python package manager written in rust, not up to date, use brew
    #vault # Hashicorp vault cli @dbcicd #Takes too long to build, using brew
    vendir
    # vscode # Shell integration always resolves symlinks, leading to broken Dock icons and Automator Actions, using brew instead
    watchexec
    wget
    #which # Non-standard version, does not support "-s"
    xz
    yapf
    yazi # terminal file manager
    yq
    zellij # terminal multiplexer a la tmux with programmable layouts, nice for shell demos
    zip
    zstd
  ];

  # TODO To make this works, homebrew needs to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true; # runs an brew update on any darwin-rebuild. Slow.
      # 'zap': uninstalls all formulae(and related files) not listed here.
      #cleanup = "zap";
      # I need to keep surplus formulae for now (i.e., until a way is found to handle formulae device-specific)
      cleanup = "none";
      upgrade = true;
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      "Affinity Designer 2" = 1616831348;
      "Affinity Photo 2" = 1616822987;
      "Affinity Publisher 2" = 1606941598;
      "ColorSlurp" = 1287239339;
      "Consent-O-Matic" = 1606897889;
      #"Core Tunnel" = 1354318707; # Appstore version cannot do advanced things, see https://community.codinn.com/t/core-tunnel-difference-between-codinn-store-and-app-store-versions/4590 . Using cask instead.
      "EasyFind" = 411673888;
      "Free Ruler" = 1483172210;
      "Gapplin" = 768053424;
      "HazeOver" = 430798174;
      "Kagi for Safari" = 1622835804;
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
      "emqx/mqttx"
    ];

    brews = [
      "cliclick"
      #"curl" # Moved to nixpkg
      "docker" # cli part of docker. Try using nix app?
      #"imagemagick" # Moved to nixpkg
      #"openjdk@21" # To activate: sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk # Replaced with nixpkg
      #"inotify-tools" # No aarch64-apple-darwin
      "ipinfo-cli"
      #"iproute2mac" # Moved to nixpkg darwin.iproute2mac
      "jfrog-cli" # CLI for Artifactory @dbcicd
      #"k3d" #using nix
      "kcl-lang/tap/kcl" # Tool to create an abstratction layer for k8s manifests # Available from nixpkg as "kcl-cli" but missing kcl-lsp
      "kcl-lsp" # kcl language server (for vscode)
      "lz4"
      "lzo"
      "mpdecimal"
      "emqx/mqttx/mqttx-cli" # https://mqttx.app
      #"openssl@3" # dependency of e.g. vault-cli
      "openssh"
      "pandoc"
      "ruff" # fast python linter
      "rustup-init"
      #"readline"
      "screen"
      "switchaudio-osx"
      "terraform"
      "uv" # python package manager
      "vault-cli"
    ];

    #caskArgs = { # Error: "The option `homebrew.caskArgs.greedy' does not exist."
    #  greedy = true;
    #};

    casks = [
      #"raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      {
        name = "aldente";
        greedy = true;
      }
      {
        name = "alfred";
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
        name = "camo-studio";
        greedy = true;
      }
      {
        name = "choosy";
        greedy = true;
      }
      #{ # Cannot be opened by MacOS 2024-07-31)
      #  name = "chromium";
      #  greedy = true;
      #}
      {
        name = "core-tunnel";
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
        name = "discord";
        greedy = true;
      }
      {
        name = "docker";
        greedy = true;
      }
      {
        name = "elgato-control-center";
        greedy = true;
      }
      #{ # Not better than webapp
      #  name = "figma";
      #  greedy = true;
      #}
      #{ # Pixel collab world
      #  name = "gather";
      #  greedy = true;
      #}
      #{
      #  name = "gimp";
      #  greedy = true;
      #}
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
        name = "lynx";
        greedy = true;
      }
      {
        name = "macfuse";
        greedy = true;
      }
      #{ # Not better than webapp
      #  name = "miro";
      #  greedy = true;
      #}
      #{ # This is the (useless) GUI App. Use mqttx-cli above instead
      #  name = "mqttx";
      #  greedy = true;
      #}
      {
        name = "obsidian";
        greedy = true;
      }
      {
        name = "openlens";
        greedy = true;
      }
      {
        name = "orion";
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
      #{ # Not allowed on DB Mac
      #  name = "rustdesk";
      #  greedy = true;
      #}
      {
        name = "sf-symbols";
        greedy = true;
      }
      { # PDF viewer/editor
        name = "skim";
        greedy = true;
      }
      {
        name = "slack";
        greedy = true;
      }
      #{ # requires /usr/bin/java which is only available on BWP (reason unknown)
      #  name = "squirrelsql";
      #  greedy = true;
      #}
      {
        name = "suspicious-package";
        greedy = true;
      }
      { # Prefpane to configure default apps for filename extension and Uri schemes
        name = "swiftdefaultappsprefpane";
        greedy = true;
      }
      {
        name = "telegram";
        greedy = true;
      }
      {
        name = "transmit";
        greedy = true;
      }
      { # Versatile and reliable host-to-host sync
        name = "unison";
        greedy = true;
      }
      {
        name = "visual-studio-code";
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
      {
        name = "zed";
        greedy = true;
      }
    ];
  };
}
