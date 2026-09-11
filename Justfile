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

# Run shell script tests
test:
  bats -p tests

# Update flake inputs to most recent version
update:
  sudo littlesnitch rulegroup --enable update
  -nix flake update
  sudo littlesnitch rulegroup --disable update

# Re-apply flake after build has been run once
[private]
_apply darwin_variant:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)

      case "{{darwin_variant}}" in
        default)
          flake_target="{{HOSTNAME}}"
          message="Applying darwin configuration for {{HOSTNAME}}"
          ;;
        nix-only)
          flake_target="{{HOSTNAME}}-nix-only"
          message="Applying darwin configuration for {{HOSTNAME}} without Homebrew update"
          ;;
        *)
          echo "Unsupported darwin apply variant '{{darwin_variant}}'." >&2
          exit 1
          ;;
      esac

      echo "$message"
      sudo littlesnitch rulegroup --enable update
      sudo darwin-rebuild switch --flake ".#$flake_target"
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

# Re-apply flake
apply:
  just _apply default

# Re-apply flake without triggering Homebrew auto-update
apply-nix-only:
  just _apply nix-only

# Login to OpenBao and place tokens properly. Additional `bao login` args may be supplied.
bao-login *bao_login_args:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin|linux)
      echo "Running 'bao login' on ${BAO_ADDR} as user ${USER}"
      bao login {{bao_login_args}}
      echo "Installing OpenBao system token to /etc/bao.token (root-only)"
      sudo install -m 0600 -o root -g wheel "$HOME/.vault-token" /etc/bao.token
      ;;
    windows)
      echo "OpenBao system token install is not supported for windows/home-manager-only targets." >&2
      exit 1
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Convenience target to login with my user
bao-login-stefan:
  just bao-login -method=ldap username=stefan

# Force an immediate refresh of system-level OpenBao secrets (requires sudo)
refreshsecrets-system:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Refreshing system OpenBao secrets on darwin for {{HOSTNAME}}"
      label="ststefanix.bao-agent-system-secrets"
      current_plist="/run/current-system/Library/LaunchDaemons/$label.plist"
      installed_plist="/Library/LaunchDaemons/$label.plist"
      log_file="/var/log/bao-agent-system-secrets.log"
      plist=""

      if [ -f "$current_plist" ]; then
        plist="$current_plist"
      elif [ -f "$installed_plist" ]; then
        plist="$installed_plist"
      fi

      if sudo launchctl print "system/$label" >/dev/null 2>&1; then
        sudo launchctl bootout "system/$label" || true
        # Wait for bootout to complete
        for _ in 1 2 3 4 5 6 7 8 9 10; do
          if ! sudo launchctl print "system/$label" >/dev/null 2>&1; then
            break
          fi
          sleep 0.2
        done
        if [ -z "$plist" ]; then
          echo "Configured OpenBao system daemon is loaded, but no plist was found to bootstrap." >&2
          exit 1
        fi
        sudo launchctl bootstrap system "$plist"
      elif [ -n "$plist" ]; then
        sudo launchctl bootstrap system "$plist"
      else
        echo "No system secrets configured for this host, thus no system OpenBao secrets launch daemon is active." >&2
        echo "If you just added it, run 'just apply' first." >&2
        exit 0
      fi

      timeout 5 bash -lc 'tail -n0 -f "$1" | grep -m1 ERROR' _ "$log_file" || true
      ;;
    linux)
      echo "Refreshing system OpenBao secrets on linux for {{HOSTNAME}}"
      sudo systemctl restart bao-agent-system-secrets
      ;;
    windows)
      echo "System OpenBao secrets refresh is not supported for windows/home-manager-only targets." >&2
      exit 1
      ;;
    *)
      echo "Unsupported os '$os' for host '{{HOSTNAME}}'." >&2
      exit 1
      ;;
  esac

# Force an immediate refresh of user-level OpenBao secrets (no sudo)
refreshsecrets-user:
  #!/usr/bin/env bash
  set -eu

  os="$(just _host-os)"

  case "$os" in
    darwin)
      echo "Refreshing user OpenBao secrets on darwin for {{HOSTNAME}}"
      uid="$(id -u)"
      domain="gui/$uid"
      label="ststefanix.bao-agent-user-secrets"
      plist="$HOME/Library/LaunchAgents/$label.plist"
      log_file="$HOME/Library/Logs/bao-agent-user-secrets.log"

      if launchctl print "$domain/$label" >/dev/null 2>&1; then
        launchctl bootout "$domain/$label" || true
        # Wait for bootout to complete
        for _ in 1 2 3 4 5 6 7 8 9 10; do
          if ! launchctl print "$domain/$label" >/dev/null 2>&1; then
            break
          fi
          sleep 0.2
        done
        if [ -f "$plist" ]; then
          launchctl bootstrap "$domain" "$plist"
        else
          echo "Configured OpenBao user agent is loaded, but no plist was found to bootstrap." >&2
          exit 1
        fi
      elif [ -f "$plist" ]; then
        launchctl bootstrap "$domain" "$plist"
      else
        echo "No user secrets configured for this host, thus no user OpenBao secrets launch agent is active." >&2
        echo "If you just added it, run 'just apply' first." >&2
        exit 0
      fi

      timeout 5 bash -lc 'tail -n0 -f "$1" | grep -m1 ERROR' _ "$log_file" || true
      ;;
    linux)
      echo "Refreshing user OpenBao secrets on linux for {{HOSTNAME}}"
      systemctl --user restart bao-agent-user-secrets
      ;;
    windows)
      echo "User OpenBao secrets refresh is not supported for windows/home-manager-only targets yet." >&2
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

  just refreshsecrets-user
  sudo just refreshsecrets-system

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

# Wipe profiles older than 30 days and do a nix garbage-collect
gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 30d
  nix store gc
