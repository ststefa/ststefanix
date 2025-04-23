{
  pkgs,
  lib,
  cores,
  ...
}:

{
  nix.package = pkgs.nix;

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 30d";
  };

  nix.settings = {
    # Disable auto-optimise-store because of this issue:
    #   https://github.com/NixOS/nix/issues/7273
    # "error: cannot link '/nix/store/.tmp-link-xxxxx-xxxxx' to '/nix/store/.links/xxxx': File exists"
    auto-optimise-store = false;

    # Set build core explicitly because some tools use it to calculate parallelism
    cores = cores;

    # enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Blanket permission for unfree packages
  #nixpkgs.config.allowUnfree = true;
  # Allow packages explicitly instead of blanket permission
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "terraform"
      "vault"
    ];

  # Obsoleted with update on 2025-03-09
  ## Auto upgrade nix package and the daemon service.
  #services.nix-daemon.enable = true;
  ## Use this instead of services.nix-daemon.enable if you
  ## don't wan't the daemon service to be managed for you.
  ## nix.useDaemon = true;

  # add overlays to make updated derivations of existing modules
  nixpkgs.overlays = [
    (final: prev: {
      #k3d = prev.k3d.overrideAttrs (oldAttrs: rec {
      #  version = "5.7.3";
      #  src = prev.fetchFromGitHub {
      #    owner = "k3d-io";
      #    repo = "k3d";
      #    rev = "refs/tags/v${version}";
      #    hash = "sha256-G9z4yJ7Oa2zmxYTRIMCiXlBPLlc3vGPUqUOoIohDKU8=";
      #  };
      #});

      #uv = prev.uv.overrideAttrs (oldAttrs: rec {
      #  version = "0.4.4";
      #  src = prev.fetchFromGitHub {
      #    owner = "astral-sh";
      #    repo = "uv";
      #    rev = version;
      #    hash = "sha256-PhLatO4XeYFrv0DqPc0NlSGXJvLkem0pqxEcoVZddZw=";
      #  };
      #});

      #ruff = prev.ruff.overrideAttrs (oldAttrs: rec {
      #  version = "0.5.0";
      #  src = prev.fetchFromGitHub {
      #    owner = "astral-sh";
      #    repo = "ruff";
      #    rev = version;
      #    hash = "";
      #  };
      #});

      #ruff = prev.ruff.override {
      #  version = "0.5.0";
      #};
    })
  ];
}
