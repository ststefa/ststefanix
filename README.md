# ststefanix

Nix configuration organized by clear axes: `nix`, `os`, `client`, and `home`.
The goal is predictable composition, minimal duplication, and explicit ownership of settings.

## Concept Overview

This repo models a host configuration as layered deltas:

1. `nix/*` defines cross-platform system foundation.
2. `os/<os>/*.nix` defines platform-specific behavior.
3. `clients/<client>/*.nix` defines client/role-specific system deltas.
4. `home/default.nix` defines user-level baseline, then imports OS/client home deltas.

Think of it as: **foundation -> platform -> role -> user**.

## Axes and Ownership

- `nix/` owns shared system concerns:
  - `nix/core.nix`: Nix settings + host identity baseline.
  - `nix/apps.nix`: shared `environment.systemPackages` baseline.
  - `nix/shell.nix`: shared shell/env defaults.
  - `nix/sudoers.nix`: shared sudoers assembly logic.
- `os/` owns platform constraints and capabilities:
  - `os/<os>/system.nix`, `os/<os>/apps.nix`, `os/<os>/home.nix`.
  - optional `os/<os>/overlays.nix` for platform-only overlay workarounds.
- `clients/` owns host-role differences:
  - `clients/<client>/<os>.nix` for system deltas.
  - `clients/<client>/home.nix` for Home Manager deltas.
- `home/` owns user-level reusable modules and files.

Rule: place code where its **reason to change** belongs.

## Inventory-Driven Composition

`inventory/hosts.nix` is the source of truth for host metadata.
Each host entry provides identity and runtime facts (for example `client`, `os`, `system`, `username`, `cores`).

`flake.nix` reads inventory and derives outputs by OS:

- `darwinConfigurations` for hosts with `os = darwin`
- `nixosConfigurations` for hosts with `os = linux`
- `homeConfigurations` for hosts with `os = windows` (WSL/Home Manager target)

Inventory attributes are passed via `specialArgs`, so modules can be parameterized without hardcoding host names.

## Sudoers Strategy

Sudoers is assembled declaratively in `nix/sudoers.nix` from plain ASCII fragments:

- OS fragment: `os/<os>/files/etc/sudoers`
- optional client fragment: `clients/<client>/files/etc/sudoers`

The merged result is written to `/etc/sudoers.d/nix-${username}`.
This keeps content editable as text while preserving declarative composition.

## Home Manager Placement Rules

- Global user behavior: `home/*.nix` (for example `home/shell.nix`, `home/git.nix`).
- OS-specific user behavior: `os/<os>/home.nix`.
- Client-specific user behavior: `clients/<client>/home.nix`.

`home.file` definitions are merged by target path; collisions only happen when the same destination is declared twice.

## Operational Workflow

Use `just` as the primary entrypoint:

- `just build`: build current host output from inventory.
- `just diff`: compare current generation with newly built result.
- `just apply`: switch to the built configuration for current host OS.
- `just rollback`: rollback one generation.

`just` resolves host OS from `.#hostInventory.<hostname>.os`.

## Design Intent

This layout prefers explicit structure over implicit magic:

- fewer hidden couplings,
- easier refactors,
- host portability via inventory,
- clean boundaries between foundation, platform, role, and user settings.
