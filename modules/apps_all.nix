{ pkgs, ... }@args: {

  ##########################################################################
  #
  #  Install all apps and packages here.
  #
  #  NOTE: Your can find all available options in:
  #    https://daiderd.com/nix-darwin/manual/index.html
  #
  ##########################################################################

  # Generate a file containing installed packages
  # Generates a separate file for every invocation which will be removed as part of nix gc
  # find and compare them using `ls -l /nix/store/*nix-packages`
  environment.etc."nix-packages".text =
  let
    packages = builtins.map (p: "${p.name}") args.config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in
    formatted;

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
    #cmakeMinimal # using brew for compiler-related
    colima
    colmena # NixOS deployment tool, https://github.com/zhaofengli/colmena
    coreutils
    cowsay
    curl
    iproute2mac # some features of iproute2 for MacOS
    darwin.trash # cli tool that mimics rm but uses the system trashcan
    #diffoscope # takes long to bui
    diffutils
    #docker # does not include docker daemon
    #docutils #using brew for all py-related
    doxygen # required to build gr-osmosdr
    dutree
    exiftool
    #ffmpeg-full # does not provide libavformat.dylib which is required for audacity, using brew
    figlet
    file
    findutils # GNU find, locate, updatedb, xargs
    fortune
    fswatch
    fzf
    gawk
    #gcc # using brew for compiler-related
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
    htop # Colored top
    imagemagick
    #inotify-tools #No aarch64-apple-darwin
    iperf
    #jdk21_headless # does not provide bin, use temurin instead
    #jfrog-cli # Artifactory cli @dbcicd #Outdated on unstable
    jinja2-cli
    jq
    just
    k3d #up to date in unstable
    #k3s
    k9s
    #kcl-cli # kcl-lsp not available, so using brew for all kcl
    krew
    kubectl
    kubernetes-helm
    kustomize
    lefthook # git hook setup helper
    less
    lima
    #llvm_18 #not found anymore
    lsof
    mas # Mac Appstore cli
    minio-client
    #mqttx Not available for aarch64-apple-darwin
    nixd # nix language server, used by vscode nix plugin
    nixfmt-rfc-style # NIX default dormatter
    nmap
    #nnn # terminal file manager, replaced by yazi
    nodejs
    nodePackages.cspell
    oath-toolkit # Provides oathtool
    #openlens # not available for aarch64-darwin
    #openssh # sometimes aborts sessions with "package too long" errors, esp. on apume. Using brew.
    opentofu # OSS fork of terraform
    parallel
    pdfminer # PDF parser and analyzer
    pipx
    poetry
    pstree
    psutils
    pv
    # Using python from brew because
    # - gnuradio cannot compile grosmosdr (missing python libs)
    #python311
    #python311Packages.coverage
    #python311Packages.debugpy
    # python311Packages.docutils #build error in unstable
    #python311Packages.jsonpatch
    #python311Packages.keyring
    #python311Packages.pip
    #python311Packages.pylint
    #python311Packages.pytest
    #python311Packages.restructuredtext-lint
    #python311Packages.rstcheck # python3.11-rstcheck-core-1.0.3.drv tests fail
    #python311Packages.sphinx #build error in unstable
    #python311Packages.virtualenv
    #python311Packages.wheel
    qemu_kvm
    ripgrep
    #rstcheck # python3.11-rstcheck-core-1.0.3.drv tests fail
    #ruby # does somehow mess up with installing gems
    #ruby-lsp # language server used by vscode ruby extension. Does not work due to version mismatch in prism lib
    #ruff # not up to date, use brew
    #rustdesk # not up to date, use brew
    #rustup cleanup on hudson required first
    shellcheck
    sipcalc # nice cli for subnet calculation
    socat
    sops
    sphinx
    sqlite
    sslscan
    stern
    stress-ng
    tcpdump
    #temurin-bin-21 # java
    terraform # Unfree, takes long to build
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
    vault # Hashicorp vault cli # Unfree, Takes long to build
    vendir
    # vscode # Shell integration always resolves symlinks, leading to broken Dock icons and Automator Actions, using brew instead
    watchexec
    wget
    #which # Non-standard version, does not support "-s"
    xterm
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
    # On 2025-04-11, `mas list` shows no output. This leads to reinstall on every nix invocation. Probably some changes in Apples APIs. Disabling entire masApps.
    # On 2025-04-16 it works again. Enabling masApps.
    masApps = {
      "Affinity Designer 2" = 1616831348;
      "Affinity Photo 2" = 1616822987;
      "Affinity Publisher 2" = 1606941598;
      "Amphetamine" = 937984704;
      "ColorSlurp" = 1287239339;
      "Consent-O-Matic" = 1606897889;
      #"Core Tunnel" = 1354318707; # Appstore version cannot do advanced things, see https://community.codinn.com/t/core-tunnel-difference-between-codinn-store-and-app-store-versions/4590 . Using cask instead.
      "djay Pro" = 450527929;
      "EasyFind" = 411673888;
      "Free Ruler" = 1483172210;
      "Gapplin" = 768053424;
      "HazeOver" = 430798174;
      "com.kagimacOS.Kagi-Search" = 1622835804;
      "Keynote" = 409183694;
      "Meeter" = 1510445899;
      "Mona" = 1659154653;
      "Msg Viewer Pro" = 1019539949;
      "Numbers" = 409203825;
      "OCRKit" = 410309628;
      "Pages" = 409201541;
      "Sandkorn" = 1377973524;
      "Strongbox" = 897283731;
      "VisualDesigner" = 1193683552;
      "WiFi Explorer" = 494803304;
      "WiFi Signal" = 525912054;
      "Windows App" = 1295203466; # Formerly MS Remote Desktop
      "Xcode" = 497799835;
    };

    # Taps *must* be declared here if brews are installed from them. Also for brews installed in host-specific apps!
    taps = [
      "hashicorp/tap"
      "homebrew/services"
      "kcl-lang/tap"
      "emqx/mqttx"
      "messense/macos-cross-toolchains"
      "puppetlabs/puppet"
    ];

    brews = [
      "bash-completion@2"
      "binutils"
      "boost"
      "ca-certificates"
      "cairo" # dependency of e.g. ffmpeg, ghostscript, gnuradio
      "cliclick"
      "cmake"
      #"curl" # Moved to nixpkg
      "docker" # cli part of docker. Try using nix app?
      "docutils"
      "doxygen"
      "ffmpeg"
      "gcc"
      "gossip" # A GUI client for nostr. This is a GUI app, but its not a cask. Start it by executing `gossip` in the terminal.
      "graphviz"
      "harfbuzz"
      #"imagemagick" # Moved to nixpkg
      "jfrog-cli" # CLI for Artifactory
      "llvm" #
      "lld" # LLVM linker
      "openjdk@23" # To activate: sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk to attach Apple wrappers. Or add /opt/homebrew/opt/openjdk/bin to PATH to have it invoked directly.
      "hashicorp/tap/vault"
      #"inotify-tools" # No aarch64-apple-darwin
      "ipinfo-cli"
      #"iproute2mac" # Moved to nixpkg darwin.iproute2mac
      #"k3d" #using nix
      "kcl-lang/tap/kcl" # Tool to create an abstraction layer for k8s manifests # Available from nixpkg as "kcl-cli" but missing kcl-lsp
      "kcl-lsp" # kcl language server (for vscode)
      "libheif"
      "libidn2" # dependency of e.g. ffmpeg, gnutls, wget
      "libpng"
      "libx11"
      "lynx"
      "lz4"
      "lzo"
      "mpdecimal"
      "emqx/mqttx/mqttx-cli" # https://mqttx.app
      "ollama"
      #"openssl@3" # dependency of e.g. vault-cli
      "openssh"
      "pandoc"
      "pipx"
      "pkgconf"
      "python@3.13"
      "ruby"
      "ruff" # fast python linter
      "rustup"
      #"readline"
      "screen"
      "switchaudio-osx"
      #"terraform" # deprecated in homebrew
      "uv" # python package manager written in Rust
      #"vault-cli" # This is "Jackrabbit FileVault"
      "zstd"
    ];

    #caskArgs = { # Error: "The option `homebrew.caskArgs.greedy' does not exist."
    #  greedy = true;
    #};

    casks = [
      #"raycast" # (HotKey: alt/option + space)search, calculate and run scripts(with many plugins)
      { name = "aldente"; greedy = true; } # Save the battery of your Macbook
      { name = "alfred"; greedy = true; }
      { name = "apparency"; greedy = true; } # Analyze app signatures
      { name = "bartender"; greedy = true; } # Manage menubar items
      { name = "betterdisplay"; greedy = true; }
      { name = "betterzip"; greedy = true; }
      { name = "camo-studio"; greedy = true; }
      { name = "chatgpt"; greedy = true; }
      { name = "choosy"; greedy = true; } # Customize URL opening behaviour
      #{ name = "chromium"; greedy = true; } # Cannot be opened by MacOS 2024-07-31)
      { name = "core-tunnel"; greedy = true; } # Comprehensive ssh tunnel GUI
      { name = "db-browser-for-sqlite"; greedy = true; }
      { name = "deepl"; greedy = true; }
      { name = "discord"; greedy = true; }
      { name = "docker"; greedy = true; }
      { name = "downie"; greedy = true; } # Video downloader, works together with permute
      { name = "elgato-control-center"; greedy = true; }
      #{ name = "figma"; greedy = true; } # Not better than webapp
      { name = "hammerspoon"; greedy = true; } # Tap into the MacOS event system
      { name = "imazing"; greedy = true; } # IOS backup tool
      { name = "istat-menus"; greedy = true; }
      { name = "iterm2"; greedy = true; }
      { name = "launchcontrol"; greedy = true; }
      { name = "little-snitch"; greedy = true; }
      { name = "macfuse"; greedy = true; }
      { name = "microsoft-teams"; greedy = true; }
      #{ name = "miro"; greedy = true; } # Not better than webapp
      #{ name = "mqttx"; greedy = true; } # This is the (useless) GUI App. Use mqttx-cli above instead
      { name = "obsidian"; greedy = true; }
      { name = "openlens"; greedy = true; } # GUI for kubernetes
      { name = "orion"; greedy = true; } # Web browser
      { name = "paletro"; greedy = true; } # Use App menus with the keyboard
      { name = "permute"; greedy = true; } # Video converter, works together with downie
      { name = "qlmarkdown"; greedy = true; } # QuickLook plugin for markdown
      { name = "qlstephen"; greedy = true; } # QuickLook plugin for multiple file types
      { name = "quicklook-csv"; greedy = true; } # QuickLook plugin for csv
      { name = "quicklook-json"; greedy = true; } # QuickLook plugin for json
      #{ name = "rustdesk"; greedy = true; } # Not allowed on DB Mac
      { name = "sf-symbols"; greedy = true; } # A nicely curated set of symbols by Apple
      { name = "skim"; greedy = true; } # PDF viewer/editor
      { name = "slack"; greedy = true; }
      #{ name = "squirrelsql"; greedy = true; } # requires /usr/bin/java which is only available on BWP (reason unknown)
      { name = "suspicious-package"; greedy = true; } # Analyze pkg files
      { name = "swiftdefaultappsprefpane"; greedy = true; } # Prefpane to configure default apps for filename extension and Uri schemes
      { name = "telegram"; greedy = true; }
      #{ name = "theiaide"; greedy = true; } # Too slow on startup
      { name = "transmit"; greedy = true; } # MacOS FTP app
      { name = "unison"; greedy = true; } # Versatile and reliable host-to-host sync
      { name = "visual-studio-code"; greedy = true; }
      { name = "vlc"; greedy = true; } # Universal video player
      { name = "wireshark"; greedy = true; } # Analyze network data
      { name = "zed"; greedy = true; }
    ];
  };
}
