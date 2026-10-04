# Cross-platform baseline packages

{ pkgs, ... }:
{
  # Common nix packages for all OS's
  environment.systemPackages = with pkgs; [
    age # A simple and secure file encryption tool
    ansible
    argocd
    argocd-autopilot
    asciinema # terminal session recorder
    atuin # Replacement for a shell history
    awscli2
    azure-cli
    bat # cat clone with syntax highlighting and Git integration
    bats # Bash Automated Testing System
    bc # Basic calculator
    #bitwarden-desktop # Bitwarden password safe GUI. Compilation fails, using brew
    #bitwarden-cli # Bitwarden password safe CLI. Using brew
    bottom # A graphical process/system monitor for the terminal
    #caddy # golang config server
    #cmakeMinimal # using brew for compiler-related
    colmena # NixOS deployment tool, https://github.com/zhaofengli/colmena
    coreutils # GNU core utilities like `ls`, `cat`, `date`, `install`, `gcp`, `gmkdir`...
    cowsay
    cspell
    curl
    d2 # Diagram scripting language
    #diffoscope # takes long to build
    diffutils # GNU diff utilities
    #docker # does not include docker daemon
    #docutils #using brew for all py-related
    dutree # Display directory tree with git status
    exiftool
    #ffmpeg-full # does not provide libavformat.dylib which is required for audacity, using brew
    figlet # ASCII art
    file
    findutils # GNU find, locate, updatedb, xargs
    fio # Flexible I/O tester
    fortune
    fswatch
    #fzf # replaced by atuin

    gawk
    #gcc # using brew for compiler-related
    gh # Github CLI
    git
    git-agecrypt
    git-crypt
    git-filter-repo # Remove files from git history (e.g. secrets)
    gitleaks # Scan repo history for secrets
    glances # nicer top
    glow # markdown previewer in terminal
    gnugrep
    gnumake
    gnupg
    gnused
    gnutar
    go # Go Programming language
    gopls # go language server
    htop # Colored top
    httpie # User-friendly cURL replacement
    imagemagick
    inetutils # replaces unixtools.net-tools (darwin-safe)
    iperf
    #jdk25_headless # does not provide bin, use temurin instead
    #jfrog-cli # Artifactory cli @dbcicd #Outdated on unstable
    jinja2-cli
    jq
    just
    k3d # up to date in unstable
    #k3s
    k9s
    #kcat # kafkacat, a client for Kafka. 2026-08-17 disabled because libserdes dep broken
    #kcl-cli # kcl-lsp not available, so using brew for all kcl
    krew # kubectl plugin manager
    kubectl
    kubernetes-helm
    kustomize
    lefthook # git hook setup helper
    less
    lsof
    minio-client
    #mqttx-cli
    nixd # nix language server, used by vscode nix plugin
    nixfmt
    nmap
    nodejs
    oath-toolkit # Provides oathtool
    oha # HTTP load generator with tui animation
    #lens # k8s GUI
    #openssh # sometimes aborts sessions with "package too long" errors, esp. on apume. Using brew.
    openbao # OSS fork of Vault
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
    secretspec # A very promising approach to secret handling, see <secretspec.dev>
    shellcheck
    shfmt # Shell (and others) formatter
    sipcalc # cli for subnet calculation
    skopeo # CLI for various operations on container images and image repositories, e.g. to copy multi-arch images
    socat
    sops
    sphinx
    sqlite
    sslscan
    stern
    stress-ng
    tcpdump
    #terraform # Unfree, takes long to build
    tesseract # OCR engine
    tflint
    tldr
    tmux
    tree
    unixtools.procps # Linux-only tools; install via onLinux if needed
    unzip
    upx # Executable file compressor. Nice for golang ;)
    #uv # python package manager written in rust, not up to date, use brew
    #vault # Hashicorp vault cli # Unfree, Takes long to build
    vendir # CLI tool to vendor portions of git repos, github releases, helm charts, docker image contents, etc. declaratively
    # vscode # Shell integration always resolves symlinks, leading to broken Dock icons and Automator Actions, using brew instead
    watchexec
    wget
    #which # Non-standard version, does not support "-s"
    xh # httpie clone written in Rust
    xterm
    xz # File compression tool. Overriden by nix app but left here due to brew dependencies
    #yapf # using ruff instead
    yazi # terminal file manager
    yq # jq for yaml
    zellij # terminal multiplexer a la tmux with programmable layouts, nice for shell demos
    zip
    zstd
  ];
}
