# just is a command runner, Justfile is very similar to Makefile, but simpler.

HOSTNAME := `hostname -s`

# Show this help
default:
    @just --list

# Build and activate nix-darwin (run once)
build:
  nix build .#darwinConfigurations.{{HOSTNAME}}.system \
    --extra-experimental-features 'nix-command flakes'
  ./result/sw/bin/darwin-rebuild switch --flake .#{{HOSTNAME}}

# Build and activate nix-darwin with debug output (run once)
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
  sudo littlesnitch rulegroup --enable update
  -nix flake update
  sudo littlesnitch rulegroup --disable update
alias update := update-flake

# Re-apply flake (requires prior build)
apply-flake:
  sudo littlesnitch rulegroup --enable update
  -darwin-rebuild switch --flake .#{{HOSTNAME}}
  sudo littlesnitch rulegroup --disable update
alias apply := apply-flake

# Show profile history
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Wipe profile history older than x and do a nix garbage-collect
gc:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 30d
  sudo nix store gc

# Remove build output
clean:
  rm -rf result
