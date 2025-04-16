# just is a command runner, Justfile is very similar to Makefile, but simpler.

HOSTNAME := `hostname -s`

# Show this help
default:
    @just --list

# Build and activate nix-darwin (run once)
build:
  nix build --extra-experimental-features 'nix-command flakes' \
    .#darwinConfigurations.{{HOSTNAME}}.system
  ./result/sw/bin/darwin-rebuild switch --flake .#{{HOSTNAME}}

# Build and activate nix-darwin with debug output (run once)
build-debug:
  nix build --extra-experimental-features 'nix-command flakes' \
    .#darwinConfigurations.{{HOSTNAME}}.system --show-trace --verbose
  ./result/sw/bin/darwin-rebuild switch --flake .#{{HOSTNAME}} --show-trace --verbose

# Everyday tasks

# Update this flake
update-flake:
  sudo littlesnitch rulegroup --enable update
  -nix flake update
  sudo littlesnitch rulegroup --disable update
alias update := update-flake

# Re-apply flake after build has been run once
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
  nix store gc

# Remove build output
clean:
  rm -rf result
