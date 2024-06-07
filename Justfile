# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Show this help
default:
    @just --list

# Build and activate nix-darwin
build HOSTNAME:
  nix build .#darwinConfigurations.{{HOSTNAME}}.system \
    --extra-experimental-features 'nix-command flakes'
  ./result/sw/bin/darwin-rebuild switch --flake .#{{HOSTNAME}}

# Build and activate nix-darwin with debug output
build-debug HOSTNAME:
  nix build .#darwinConfigurations.{{HOSTNAME}}.system --show-trace --verbose \
    --extra-experimental-features 'nix-command flakes'
  ./result/sw/bin/darwin-rebuild switch --flake .#{{HOSTNAME}} --show-trace --verbose

############################################################################
#
#  nix related commands
#
############################################################################

# Update this flake
update-flake:
  nix flake update

# Re-apply flake (requires prior build)
apply-flake HOSTNAME:
  darwin-rebuild switch --flake .#{{HOSTNAME}}

# Show profile history
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Wipe profile history older than 7d and do a nix garbage-collect
gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
  sudo nix store gc --debug

# Remove build output
clean:
  rm -rf result
