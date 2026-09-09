# OS-level Darwin package baseline.

{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    colima # Docker on macOS with Lima
    darwin.trash # cli tool that mimics rm but uses the system trashcan
    iproute2mac # some features of iproute2 for macOS
    lima # Linux virtual machines on macOS
    mas # Mac App Store cli
  ];

  # The apps installed by homebrew are not managed by nix, and not reproducible!
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
      #"Affinity Designer 2" = 1616831348; # Removed from Appstore
      #"Affinity Photo 2" = 1616822987; # Removed from Appstore
      "Affinity Publisher 2" = 1606941598;
      "Amphetamine" = 937984704;
      "ColorSlurp" = 1287239339;
      "Consent-O-Matic" = 1606897889;
      #"Core Tunnel" = 1354318707; # Appstore version cannot do advanced things, see https://community.codinn.com/t/core-tunnel-difference-between-codinn-store-and-app-store-versions/4590 . Using cask instead.
      "DuckDuckGo & optional Duck.ai" = 663592361; # Need a dedicated minimal Browser for parallel OIDC Sessions. Install from Appstore to prevent brew/nix problem with changing paths, which conflicts with Apple TCC
      #"EasyFind" = 6739447813; # No longer available on appstore
      "Free Ruler" = 1483172210; # Visual screen ruler
      "Gapplin" = 768053424; # SVG viewer
      "HazeOver" = 430798174; # Screen dimmer
      "iPreview" = 1519213509; # Enables Quicklook for multiple filetypes
      "com.kagimacOS.Kagi-Search" = 1622835804;
      "Keynote" = 409183694;
      "Meeter" = 1510445899;
      "Mona" = 1659154653;
      "Msg Viewer Pro" = 1019539949;
      "Numbers" = 409203825;
      "OCRKit" = 410309628;
      #"Pages" = 409201541; # Removed from Appstore
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
      "artifact-keeper/tap"
      "emqx/mqttx"
      "hashicorp/tap"
      "kcl-lang/tap"
      "messense/macos-cross-toolchains"
      "puppetlabs/puppet"
      #"homebrew/services" # deprecated
    ];

    brews = [
      "at-spi2-core" # Protocol definitions and daemon for D-Bus at-spi
      #"atuin" # Improved shell history with sync # Moved to nixpkgs
      "bash" # The almighty GNU Bourne Again SHell
      "bash-completion@2" # Bash completion scripts
      "binutils" # GNU binary utilities
      "bitwarden-cli"
      "boost" # C++ libraries
      "ca-certificates" # Mozilla CA bundle
      "cairo" # dependency of e.g. ffmpeg, ghostscript, gnuradio
      "certifi" # Mozilla CA bundle for Python
      "cliclick" # Command line interface for macOS mouse and keyboard events
      "cmake" # Cross-platform make
      "coder" # Cloud IDE for Developers, "slim" cli-only
      #"coder/coder/coder" # Cloud IDE for Developers, cli+server
      "container" # MacOS container system (github.com/apple/container)
      "cpu_features" # Cross platform C99 library to get cpu features at runtime
      #"curl" # using nixpkg instead
      "diff-pdf" # compare pdf files visually
      "docker" # cli part of docker. Try using nix app?
      "docutils" # Python text processing system for reStructuredText
      "doxygen" # Generate documentation for several programming languages
      "emqx/mqttx/mqttx-cli" # https://mqttx.app
      "ffmpeg" # Audio/Video processing library
      "fjira" # CLI for JIRA
      "fmt" # Formatting library for C++
      "freetype" # Software library to render fonts
      "gcc" # GNU compiler collection
      "gettext" # GNU internationalization (i18n) and localization (l10n) library
      "gnupg" # GNU Privacy Guard
      "gossip" # A GUI client for nostr. This is a GUI app, but its not a cask. Start it by executing `gossip` in the terminal.
      "graphviz" # Graph visualization tools
      "harfbuzz" # OpenType text shaping engine
      "hashicorp/tap/vault" # Replaced by openbao, but sometimes needed due to compatibility with docs
      "hwloc" # Portable abstraction of the hierarchical topology of modern architectures
      #"imagemagick" # using nixpkg instead
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
      "ipinfo-cli" # Command-line interface for IPinfo.io
      #"iproute2mac" # using nixpkg instead
      #"k3d" # using nixpkg instead
      "kcl-lang/tap/kcl" # Tool to create an abstraction layer for k8s manifests # Available from nixpkg as "kcl-cli" but missing kcl-lsp
      "kcl-lsp" # kcl language server (for vscode)
      "libarchive" # Multi-format archive and compression library
      "libgcrypt" # Cryptographic library based on the code from GnuPG
      "libgpg-error" # Common error values for all GnuPG components
      "libheif" # ISO/IEC 23008-12:2017 HEIF file format decoder and encoder
      "libidn2" # dependency of e.g. ffmpeg, gnutls, wget
      "libksba" # X.509 and CMS library
      "libomp" # LLVM's OpenMP runtime library
      "libpng" # Library for manipulating PNG images
      "librsvg" # Library to render SVG files using Cairo
      "libunistring"
      "libx11" # X11 client-side library
      "lynx" # Text-based web browser
      "lz4" # Extremely Fast Compression algorithm
      "lzo" # Real-time data compression library
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
      "r" # R data visualization language
      "rav1e" # AV1 video encoder, req. by ffmpeg
      "readline" # Library for command-line editing
      "rpds-py" # Python bindings to Rust's persistent data structures
      "ruby"
      #"ruff" # fast python linter. Disabled, managed by uv
      "rustup" # Rust toolchain manager
      "screen"
      "sdl2" # Low-level access to audio, keyboard, mouse, joystick, and graphics
      "svt-av1" # AV1 video encoder, req. by ffmpeg
      "switchaudio-osx" # macOS audio source cli (SwitchAudioSource)
      #"terraform" # deprecated in homebrew
      "terratag" # A tool to tag your cloud infrastructure resources
      "tesseract" # req. by ffmpeg and ghostscript
      "unbound" # DNS resolver
      "uv" # python package manager written in Rust
      #"vault-cli" # This is "Jackrabbit FileVault" which has nothing to do with Hashicorp
      "yt-dlp" # audio/video downloader
      "z3" # High-performance theorem prover
      "zstd" # Zstandard is a real-time compression algorithm
    ];

    # This makes cask updates greedy by default. To disable it for a specific cask, set `greedy = false` for it, e.g.:
    # { name = "fooapp"; greedy = false; }
    greedyCasks = true;

    casks = [
      { name = "aldente"; } # Save the battery of your Macbook
      { name = "alfred"; } # App launcher with many plugins
      { name = "alt-tab"; } # App switcher
      { name = "apparency"; } # Analyze app signatures
      { name = "bartender"; } # Manage menubar items
      { name = "betterdisplay"; } # Manage external monitors better
      { name = "betterzip"; }
      { name = "bitwarden"; }
      { name = "camo-studio"; } # Advanced webcam
      { name = "chatgpt"; } # Official ChatGPT desktop client
      { name = "choosy"; } # Customize URL opening behaviour
      { name = "claude"; } # Anthropic's AI desktop client
      #{ name = "claude-code"; } # Integrates with zed. Requires paid subscription
      { name = "context"; } # Model Context Protocol (MCP) debugger
      { name = "core-tunnel"; } # Comprehensive ssh tunnel GUI
      { name = "db-browser-for-sqlite"; }
      { name = "deepl"; }
      { name = "discord"; }
      { name = "docker-desktop"; }
      { name = "downie"; } # Video downloader, works together with permute
      { name = "drawpen"; } # Screen annotation tool
      { name = "elgato-control-center"; }
      { name = "headlamp"; } # Kubernetes dashboard. Must be manually signed using `xattr -dr com.apple.quarantine /Applications/Headlamp.app`
      { name = "hammerspoon"; } # Tap into the MacOS event system
      { name = "imazing"; } # IOS backup tool
      { name = "istat-menus"; }
      { name = "iterm2"; }
      { name = "kubeterm"; } # A snappy k8s ui
      { name = "launchcontrol"; }
      { name = "little-snitch"; }
      { name = "macfuse"; }
      { name = "microsoft-teams"; }
      { name = "obsidian"; }
      { name = "openlens"; } # GUI for kubernetes
      { name = "orchard"; } # UI for Apple containers
      { name = "orion"; } # Web browser
      { name = "paletro"; } # Use App menus with the keyboard
      { name = "permute"; } # Video converter, works together with downie
      #{ name = "qlmarkdown"; } # QuickLook plugin for markdown. Replaced by ipreview.appp (from appstore)
      #{ name = "qlstephen"; } # QuickLook plugin for multiple file types. Replaced by ipreview.appp (from appstore)
      #{ name = "quicklook-csv"; } # QuickLook plugin for csv. Replaced by ipreview.appp (from appstore)
      # { name = "quicklook-json"; } # QuickLook plugin for json. "Disabled because it no longer meets the criteria for acceptable casks! It was disabled on 2025-12-23."
      { name = "retrace"; } # local-only screen history recorder
      #{ name = "rustdesk"; } # VNC-like remote desktop tool
      { name = "sf-symbols"; } # A nicely curated set of symbols by Apple
      { name = "skim"; } # PDF viewer/editor
      { name = "slack"; }
      #{ name = "squirrelsql"; } # requires /usr/bin/java which is only available on BWP (reason unknown)
      { name = "suspicious-package"; } # Analyze pkg files
      { name = "swiftdefaultappsprefpane"; } # Prefpane to configure default apps for filename extension and Uri schemes
      { name = "telegram"; }
      { name = "transmit"; } # MacOS FTP app
      { name = "visual-studio-code"; }
      { name = "vlc"; } # Universal video player
      #{ name = "whatsapp"; } # Official WhatsApp client. Required for wolaro project
      { name = "wireshark-app"; } # Analyze network data
      { name = "zed"; } # Rust-based IDE, built with GPUI
      { name = "zulip"; } # Like slack, but open source
    ];
  };
}
