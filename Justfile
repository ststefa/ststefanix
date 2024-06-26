# just is a command runner, Justfile is very similar to Makefile, but simpler.

HOSTNAME := `hostname`

# Show this help
default:
    @just --list

# Build and activate nix-darwin
build:
  nix build .#darwinConfigurations.{{HOSTNAME}}.system \
    --extra-experimental-features 'nix-command flakes'
  ./result/sw/bin/darwin-rebuild switch --flake .#{{HOSTNAME}}

# Build and activate nix-darwin with debug output
build-debug:
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
alias update := update-flake

# Re-apply flake (requires prior build)
apply-flake:
  darwin-rebuild switch --flake .#{{HOSTNAME}}
alias apply := apply-flake

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
