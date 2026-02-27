# just is a command runner, Justfile is very similar to Makefile, but simpler.

HOSTNAME := `hostname -s`

# Show this help
default:
    @just --list

[private]
_host-os:
  @nix eval --raw --no-write-lock-file ".#hostInventory.{{HOSTNAME}}.os" 2>/dev/null

# Build for current host (darwin, nixos, or home-manager target)
build:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Building darwin configuration for {{HOSTNAME}}"
      nix build --extra-experimental-features 'nix-command flakes' ".#darwinConfigurations.{{HOSTNAME}}.system"
      ;;
    linux)
      echo "Building nixos configuration for {{HOSTNAME}}"
      nix build --extra-experimental-features 'nix-command flakes' ".#nixosConfigurations.{{HOSTNAME}}.config.system.build.toplevel"
      ;;
    windows)
      echo "Building home-manager configuration for {{HOSTNAME}}"
      nix build --extra-experimental-features 'nix-command flakes' ".#homeConfigurations.{{HOSTNAME}}.activationPackage"
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Everyday tasks

# Update this flake
update-flake:
  sudo littlesnitch rulegroup --enable update
  -nix flake update
  sudo littlesnitch rulegroup --disable update
alias update := update-flake

# Re-apply flake after build has been run once
apply-flake:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Applying darwin configuration for {{HOSTNAME}}"
      sudo littlesnitch rulegroup --enable update
      sudo darwin-rebuild switch --flake ".#{{HOSTNAME}}"
      sudo littlesnitch rulegroup --disable update
      ;;
    linux)
      echo "Applying nixos configuration for {{HOSTNAME}}"
      sudo nixos-rebuild switch --flake ".#{{HOSTNAME}}"
      ;;
    windows)
      echo "Applying home-manager configuration for {{HOSTNAME}}"
      home-manager switch --flake ".#{{HOSTNAME}}"
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac
alias apply := apply-flake

# Login to vault and place tokens properly. Additional vault login args may be supplied.
vault-login *vault_login_args:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin|linux)
      echo "Running 'vault login' as user $USER"
      vault login {{vault_login_args}}
      echo "Installing system token to /etc/vault.token (root-only)"
      sudo install -m 0600 -o root -g wheel "$HOME/.vault-token" /etc/vault.token
      ;;
    windows)
      echo "System Vault token install is not supported for windows/home-manager-only targets." >&2
      exit 1
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac
alias vault-login-system := vault-login

# Force an immediate refresh of system-level Vault secrets (requires sudo)
refreshsecrets-system:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Refreshing system Vault secrets on darwin for {{HOSTNAME}}"
      plist="/Library/LaunchDaemons/ststefanix.vault-agent-system-secrets.plist"
      log_file="/var/log/vault-agent-system-secrets.log"
      sudo launchctl bootout system $plist || true
      sudo launchctl bootstrap system $plist
      timeout 5 tail -n0 -f $log_file | grep ERROR || true
      ;;
    linux)
      echo "Refreshing system Vault secrets on linux for {{HOSTNAME}}"
      sudo systemctl restart vault-agent-system-secrets
      ;;
    windows)
      echo "System Vault secrets refresh is not supported for windows/home-manager-only targets." >&2
      exit 1
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Force an immediate refresh of user-level Vault secrets (no sudo)
refreshsecrets-user:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Refreshing user Vault secrets on darwin for {{HOSTNAME}}"
      plist="$HOME/Library/LaunchAgents/ststefanix.vault-agent-user-secrets.plist"
      log_file="$HOME/Library/Logs/vault-agent-user-secrets.log"
      launchctl bootout gui/$(id -u) $plist || true
      launchctl bootstrap gui/$(id -u) $plist
      timeout 5 tail -n0 -f $log_file | grep ERROR || true
      ;;
    linux)
      echo "Refreshing user Vault secrets on linux for {{HOSTNAME}}"
      systemctl --user restart vault-agent-user-secrets
      ;;
    windows)
      echo "User Vault secrets refresh is not supported for windows/home-manager-only targets yet." >&2
      exit 1
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Refresh both scopes. User scope can also be invoked directly without sudo.
refreshsecrets:
  #!/usr/bin/env bash
  set -eu

  just refreshsecrets-system
  just refreshsecrets-user

# Build and compare closure against current active generation
diff:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  # Ensure ./result points to the current build output for this host.
  just build

  case "$os" in
    darwin|linux)
      echo "Diffing current system against ./result for {{HOSTNAME}}"
      nix store diff-closures /run/current-system ./result
      ;;
    windows)
      echo "Diffing current Home Manager profile against ./result for {{HOSTNAME}}"
      if [ -e "$HOME/.local/state/nix/profiles/home-manager" ]; then
        nix store diff-closures "$HOME/.local/state/nix/profiles/home-manager" ./result
      else
        nix store diff-closures "/nix/var/nix/profiles/per-user/$USER/home-manager" ./result
      fi
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Roll back to the previous active generation
rollback:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Rolling back darwin configuration for {{HOSTNAME}}"
      sudo darwin-rebuild switch --rollback
      ;;
    linux)
      echo "Rolling back nixos configuration for {{HOSTNAME}}"
      sudo nixos-rebuild switch --rollback
      ;;
    windows)
      echo "Rolling back home-manager configuration for {{HOSTNAME}}"
      home-manager switch --rollback
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Show profile history
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Wipe profile history older than x and do a nix garbage-collect
gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 30d
  nix store gc

# Remove build output
clean:
  rm -rf result
