{
  pkgs,
  lib,
  cores,
  username,
  hostname,
  os,
  ...
}:

{
  networking.hostName = hostname;
  networking.fqdn = hostname;

  users.users."${username}" = {
    home = if os == "darwin" then "/Users/${username}" else "/home/${username}";
    description = username;
  };

  nix.package = pkgs.nix;

  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 30d";
  };

  nix.settings = {
    # Store optimization is not considered robust enough on MacOS as of 2026-10. Set to false as a safety net as it is also the default.
    auto-optimise-store = false;

    # Set build core explicitly because some tools use it to calculate parallelism
    cores = cores;

    # Enable flakes globally
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Grants extra daemon privileges: use additional binary caches and import unsigned store objects.
    # Effectively equivalent to root access, since security-critical store contents can be replaced.
    # https://nix.dev/manual/nix/2.34/command-ref/conf-file.html#conf-trusted-users
    trusted-users = [ username ];
  };

  nixpkgs.config = {
    # Control the use of unfree software. Packages that cannot be redistributed are not served by cache.nixos.org.
    # Without a substitute or an existing local output, Nix must build the derivation locally.
    # This may just repackage upstream binaries; recompilation is not always required.
    # Unchanged derivations reuse existing store outputs, so not every update triggers a rebuild.
    allowUnfreePredicate =
      pkg:
      # Blanket permission for all unfree packages. Don't do that.
      #nixpkgs.config.allowUnfree = true;
      # Allow individual packages explicitly instead of blanket permission.
      builtins.elem (lib.getName pkg) [
        "terraform"
        "vault"
      ];

    # Allow individual packages marked as broken (package name without version).
    # This is meant for temporary update-debugging. It is likely a bad idea to add something here for longer.
    problems.handlers = {
      # "package-name".broken = "warn";
    };

    # Allow using individual packages marked as insecure.
    # This is meant for temporary update-debugging. It is likely a bad idea to add something here for longer.
    # Copy the exact "name-version" string from Nix's insecure-package error message.
    # It refers to the package in the nixpkgs revision pinned by flake.lock, not the latest upstream release.
    # Example: "minio-client-2025-08-13T08-35-41Z" includes the upstream release timestamp as its version.
    # After updating flake.lock, review the exception if Nix reports a different version.
    permittedInsecurePackages = [
      #"minio-client-2025-08-13T08-35-41Z"
    ];
  };
}
// lib.optionalAttrs (os == "darwin") {
  networking.computerName = hostname;
  networking.localHostName = hostname;
  # Deactivated because it causes a Mac safety popup upon build
  #system.defaults.smb.NetBIOSName = hostname;
}
