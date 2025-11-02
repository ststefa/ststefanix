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
  environment.systemPackages =
    let
      inherit (pkgs) lib stdenv;
      # Helper combinators to keep platform conditionals readable
      onlyIf = cond: xs: lib.optionals cond xs;  # return xs when cond is true, otherwise []
      onLinux = onlyIf stdenv.isLinux;
      onDarwin = onlyIf stdenv.isDarwin;
    in
    with pkgs; [
      age # A simple and secure file encryption tool
      ansible
      argocd
      argocd-autopilot
      asciinema # terminal session recorder
      awscli2
      azure-cli
      bat
      bc # Basic calculator
      bottom # A graphical process/system monitor for the terminal
      #caddy # golang config server
      #cmakeMinimal # using brew for compiler-related
      colima # Docker on macOS with Lima
      colmena # NixOS deployment tool, https://github.com/zhaofengli/colmena
      coreutils # GNU core utilities like `ls`, `cat`, `date`, `install`, `gcp`, `gmkdir`...
      cowsay
      curl
      d2 # Diagram scripting language
      iproute2mac # some features of iproute2 for MacOS
      darwin.trash # cli tool that mimics rm but uses the system trashcan
      #diffoscope # takes long to bui
      diffutils # GNU diff utilities
      #docker # does not include docker daemon
      #docutils #using brew for all py-related
      doxygen # required to build gr-osmosdr
      dutree # Display directory tree with git status
      exiftool
      #ffmpeg-full # does not provide libavformat.dylib which is required for audacity, using brew
      figlet # ASCII art
      file
      findutils # GNU find, locate, updatedb, xargs
      fio # Flexible I/O tester
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
      httpie # User-friendly cURL replacement
      imagemagick
      inetutils  # replaces unixtools.net-tools (darwin-safe)
      #inotify-tools #No aarch64-apple-darwin
      iperf
      #jdk21_headless # does not provide bin, use temurin instead
      #jfrog-cli # Artifactory cli @dbcicd #Outdated on unstable
      jinja2-cli
      jq
      just
      k3d # up to date in unstable
      #k3s
      k9s
      kcat # kafkacat, a client for Kafka
      #kcl-cli # kcl-lsp not available, so using brew for all kcl
      krew # kubectl plugin manager
      kubectl
      kubernetes-helm
      kustomize
      lefthook # git hook setup helper
      less
      lima # Linux virtual machines on macOS
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
      oha # HTTP load generator with tui animation
      #openlens # not available for aarch64-darwin
      #openssh # sometimes aborts sessions with "package too long" errors, esp. on apume. Using brew.
      opentofu # OSS fork of terraform
      oras # client for helm OCI registries
      parallel
      pdfminer # PDF parser and analyzer
      # pipx # disabled in favor of "uv tool"
      poetry # python package manager
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
      redis # client and server
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
      unixtools.procps  # Linux-only tools; install via onLinux if needed
      unzip
      upx # Executable file compressor. Nice for golang ;)
      #uv # python package manager written in rust, not up to date, use brew
      vault # Hashicorp vault cli # Unfree, Takes long to build
      vendir
      # vscode # Shell integration always resolves symlinks, leading to broken Dock icons and Automator Actions, using brew instead
      watchexec
      wget
      #which # Non-standard version, does not support "-s"
      xh # httpie clone written in Rust. Faster startup
      xterm
      xz
      #yapf # using ruff instead
      yazi # terminal file manager
      yq
      zellij # terminal multiplexer a la tmux with programmable layouts, nice for shell demos
      zip
      zstd
    ]
    # Linux-only packages and engines (do not exist or do not work on Darwin)
    ++ onLinux [
      # libguestfs
      # nbdkit
      # ceph
    ]
    # Darwin-only packages can go here
    ++ onDarwin [
      # Example: darwin.apple_sdk.frameworks.Security
    ];

  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  # Homebrew needs to be installed manually, see https://brew.sh
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
      #"EasyFind" = 6739447813; # No longer available on appstore
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
      "emqx/mqttx"
      "hashicorp/tap"
      "kcl-lang/tap"
      "messense/macos-cross-toolchains"
      "puppetlabs/puppet"
      #"homebrew/services" # deprecated
    ];

    brews = [
      "at-spi2-core" # Protocol definitions and daemon for D-Bus at-spi
      "bash" # The almighty GNU Bourne Again SHell
      "bash-completion@2" # Bash completion scripts
      "binutils" # GNU binary utilities
      "boost" # C++ libraries
      "ca-certificates" # Mozilla CA bundle
      "cairo" # dependency of e.g. ffmpeg, ghostscript, gnuradio
      "certifi" # Mozilla CA bundle for Python
      "cliclick" # Command line interface for macOS mouse and keyboard events
      "cmake" # Cross-platform make
      "coder" # Cloud IDE for Developers, "slim" cli-only
      #"coder/coder/coder" # Cloud IDE for Developers, cli+server
      "cpu_features" # Cross platform C99 library to get cpu features at runtime
      #"curl" # Moved to nixpkg
      "docker" # cli part of docker. Try using nix app?
      "docutils" # Python text processing system for reStructuredText
      "doxygen" # Generate documentation for several programming languages
      "emqx/mqttx/mqttx-cli" # https://mqttx.app
      "ffmpeg" # Audio/Video processing library
      "fjira" # CLI for JIRA
      "fmt" # Formatting library for C++
      "gcc" # GNU compiler collection
      "gettext" # GNU internationalization (i18n) and localization (l10n) library
      "gossip" # A GUI client for nostr. This is a GUI app, but its not a cask. Start it by executing `gossip` in the terminal.
      "graphviz" # Graph visualization tools
      "harfbuzz" # OpenType text shaping engine
      "hashicorp/tap/vault"
      "hwloc" # Portable abstraction of the hierarchical topology of modern architectures
      #"imagemagick" # Moved to nixpkg
      "jfrog-cli" # CLI for Artifactory
      "kubeseal" # Client for k8s sealred secrets
      "libnghttp2" # HTTP/2 C Library
      "libde265" # Open h.265 video codec
      "libssh" # C library SSHv1/SSHv2 client and server protocols
      "llvm" # LLVM compiler infrastructure
      "lld" # LLVM linker
      "m4" # Macro processing language
      "mbedtls" # Cryptographic & SSL/TLS library
      "mdp" # Command-line based markdown presentation tool
      "nettle" # Low-level cryptographic library
      "openjdk" # To activate: sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk to attach Apple wrappers. Or add /opt/homebrew/opt/openjdk/bin to PATH to have it invoked directly.
      "openssl@3" # Cryptography and SSL/TLS Toolkit
      "pango" # Framework for layout and rendering of i18n text
      #"inotify-tools" # No aarch64-apple-darwin
      "ipinfo-cli" # Command-line interface for IPinfo.io
      #"iproute2mac" # Moved to nixpkg darwin.iproute2mac
      #"k3d" #using nix
      "kcl-lang/tap/kcl" # Tool to create an abstraction layer for k8s manifests # Available from nixpkg as "kcl-cli" but missing kcl-lsp
      "kcl-lsp" # kcl language server (for vscode)
      "libarchive" # Multi-format archive and compression library
      "libheif"
      "libidn2" # dependency of e.g. ffmpeg, gnutls, wget
      "libpng"
      "libx11" # X11 client-side library
      "lynx" # Text-based web browser
      "lz4"
      "lzo"
      "mas" # Mac appstore cli
      "mingw-w64" # Minimalist GNU for Windows and GCC cross-compilers
      "mpdecimal" # Library for decimal floating point arithmetic
      "netpbm" # Image manipulation
      "ollama" # Command-line tool for running large language models
      "openldap" # dependency of lighttpd
      "open-mpi" # High performance message passing library, dependency of fftw, gnuradio, hackrf and soapyhackrf
      #"openssl@3" # dependency of e.g. vault-cli
      "openssh" # OpenSSH client and server
      "pandoc" # Swiss-army knife of markup format conversion
      # "pipx" # using uv instead
      "pixman" # pixel manipulation, dependency
      "pkgconf" # Helper tool for compiler and linker flags
      "python@3.13" # Required by several dependencies. Otherwise would be better managed by uv
      "rav1e" # AV1 video encoder, req. by ffmpeg
      "readline" # Library for command-line editing
      "rpds-py" # Python bindings to Rust's persistent data structures
      "ruby"
      #"ruff" # fast python linter. Disabled, managed by uv
      "rustup" # Rust toolchain manager
      #"readline"
      "screen"
      "sdl2" # Low-level access to audio, keyboard, mouse, joystick, and graphics
      "svt-av1" # AV1 video encoder, req. by ffmpeg
      "switchaudio-osx" # macOS audio source cli (SwitchAudioSource)
      #"terraform" # deprecated in homebrew
      "terratag" # A tool to tag your cloud infrastructure resources
      "tesseract" # req. by ffmpeg and ghostscript
      "unbound" # DNS resolver
      "uv" # python package manager written in Rust
      #"vault-cli" # This is "Jackrabbit FileVault"
      "yt-dlp" # audio/video downloader
      "z3" # High-performance theorem prover
      "zstd" # Zstandard is a real-time compression algorithm
    ];

    # This makes cask updates greedy by default. To disable it for a specific cask, set `greedy = false` for it, e.g.:
    # { name = "fooapp"; greedy = false; }
    greedyCasks = true;

    casks = [
      #"raycast" # Like Alfred
      { name = "aldente"; } # Save the battery of your Macbook
      { name = "alfred"; } # App launcher with many plugins
      { name = "apparency"; } # Analyze app signatures
      #{ name = "bartender"; } # Manage menubar items, disabled because v6.1.0 currently crashing. Installing v5 manually from https://macbartender.com/Bartender5/
      { name = "betterdisplay"; } # Manage external monitors better
      { name = "betterzip"; }
      { name = "camo-studio"; } # Advanced webcam
      { name = "chatgpt"; } # Official ChatGPT desktop client
      { name = "choosy"; } # Customize URL opening behaviour
      #{ name = "chromium"; } # Cannot be opened by MacOS 2024-07-31)
      { name = "context"; } # Model Context Protocol (MCP) debugger
      { name = "core-tunnel"; } # Comprehensive ssh tunnel GUI
      { name = "db-browser-for-sqlite"; }
      { name = "deepl"; }
      { name = "discord"; }
      { name = "docker-desktop"; }
      #{ name = "downie"; } # Video downloader, works together with permute
      { name = "drawpen"; } # Screen annotation tool
      { name = "elgato-control-center"; }
      #{ name = "figma"; } # Drawing app, not better than webapp
      { name = "headlamp"; } # Kubernetes dashboard. Must be manually signed using `xattr -dr com.apple.quarantine /Applications/Headlamp.app`
      { name = "hammerspoon"; } # Tap into the MacOS event system
      { name = "imazing"; } # IOS backup tool
      { name = "istat-menus"; }
      { name = "iterm2"; }
      { name = "launchcontrol"; }
      { name = "little-snitch"; }
      { name = "macfuse"; }
      { name = "microsoft-teams"; }
      #{ name = "miro"; } # Drawing app, not better than webapp
      #{ name = "mqttx"; } # Mostly useless GUI App. Use mqttx-cli instead
      { name = "obsidian"; }
      { name = "openlens"; } # GUI for kubernetes
      { name = "orion"; } # Web browser
      { name = "paletro"; } # Use App menus with the keyboard
      #{ name = "permute"; } # Video converter, works together with downie
      { name = "qlmarkdown"; } # QuickLook plugin for markdown
      { name = "qlstephen"; } # QuickLook plugin for multiple file types
      { name = "quicklook-csv"; } # QuickLook plugin for csv
      { name = "quicklook-json"; } # QuickLook plugin for json
      #{ name = "rustdesk"; } # VNC-like remote desktop tool
      { name = "sf-symbols"; } # A nicely curated set of symbols by Apple
      { name = "skim"; } # PDF viewer/editor
      { name = "slack"; }
      #{ name = "squirrelsql"; } # requires /usr/bin/java which is only available on BWP (reason unknown)
      { name = "suspicious-package"; } # Analyze pkg files
      { name = "swiftdefaultappsprefpane"; } # Prefpane to configure default apps for filename extension and Uri schemes
      { name = "telegram"; }
      #{ name = "theiaide"; } # Too slow on startup
      { name = "transmit"; } # MacOS FTP app
      { name = "unison-app"; } # Versatile and reliable host-to-host sync
      { name = "visual-studio-code"; }
      { name = "vlc"; } # Universal video player
      #{ name = "whatsapp"; } # Official WhatsApp client. Required for wolaro project
      { name = "wireshark-app"; } # Analyze network data
      { name = "zed"; }
      { name = "zulip"; } # Like slack, but open source
    ];
  };
}
