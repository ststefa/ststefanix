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
  - `clients/<client>/secrets.nix` for OpenBao secret mappings.
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

## OpenBao Runtime Secrets (only Linux + Darwin, not Win)

`nix/bao-secrets.nix` aggregates two scopes:

- `ststefanix.baoSystemSecrets`: root/system service (`systemd` / `launchd.daemons`)
- `ststefanix.baoUserSecrets`: user service/agent (`systemd --user` / `launchd.user.agents`)

Use `baoUserSecrets` for files in `~` (for example `~/.config/sops/...`).

Example host config (same schema on Linux and Darwin, split by scope):

```nix
{
  ststefanix.baoUserSecrets = {
    address = "https://bao.heldenzeit.net";

    secrets = {
      age_keys = {
        bao_secret = "kv/data/ststefanix/age_keys";
        # One OpenBao field contains the full keys.txt payload
        bao_secret_key = "private_key";
        destination = ".config/sops/age/keys.txt";
      };

      gh_token = {
        bao_secret = "kv/data/dev/github";
        bao_secret_key = "token";
      };
    };
  };

  # Typical Linux-style system secret example: private TLS key for nginx.
  # (On Darwin you can also use baoSystemSecrets, but the concrete consumer differs.)
  ststefanix.baoSystemSecrets = {
    secrets = {
      nginx_tls_key = {
        bao_secret = "kv/data/web/nginx_tls";
        bao_secret_key = "private_key";
        destination = "/run/secrets/nginx/tls.key";
      };
    };
  };
}
```

Important:
- `baoUserSecrets` uses `~/.vault-token` (OpenBao currently keeps Vault-compatible token helper naming; authenticate once as the inventory user via `bao login`)
- `baoSystemSecrets` uses `/etc/bao.token` (provide a separate root/system token)

Rendered secret files are owned by the account running the scope service: user-owned for `baoUserSecrets`, root-owned for `baoSystemSecrets`.

Model: one OpenBao field -> one rendered file.

Secrets are refreshed in intervals so that a change to the backend is automatically reflected locally. There is a `3m` default that lives in the shared module, so Linux and Darwin behave the same unless a scope overrides it explicitly.

Static KV secrets are re-polled every `3m` by default via `staticSecretRenderInterval`; override per scope if you need faster or slower propagation.

Scope override means setting the option on `baoUserSecrets` or `baoSystemSecrets` in the host module that owns that scope, for example:

```nix
{
  ststefanix.baoUserSecrets.staticSecretRenderInterval = "1m";
  ststefanix.baoSystemSecrets.staticSecretRenderInterval = "10m";
}
```

The natural place for that override is usually `clients/<client>/secrets.nix`, because that file already owns the host-specific OpenBao secret mapping.
For an OS-wide default, place it in `os/<os>/system.nix` or another OS-level module that owns shared OpenBao behavior.

For `baoUserSecrets`, `destination` is a path relative to `$HOME` (for example `.config/sops/age/keys.txt`). If `destination` is set, OpenBao Agent still writes the physical file into the scope runtime secrets directory, and the module creates a symlink at `destination`.

Offline/reboot behavior:

- The host still boots if OpenBao is unreachable.
- OpenBao Agent services retry in the background, but restart attempts are throttled to once per hour.
- Existing rendered secret files remain on disk (last known value) until OpenBao becomes reachable again and the agent refreshes them.
- Startup diagnostics are written to the service logs (journald on Linux, `/var/log/bao-agent-system-secrets.log` and `~/Library/Logs/bao-agent-user-secrets.log` on Darwin).

## Operational Workflow

Use `just` as the primary entrypoint:

- `just update`: update flake inputs.
- `just build`: build current host output from inventory.
- `just diff`: compare current generation with newly built result.
- `just apply`: switch to the built configuration for current host OS.
- `just apply-nix-only`: switch configuration without triggering Homebrew auto-update on Darwin.
- `just gc`: Show profile history
- `just history`: Wipe profiles older than 30 days and do a nix garbage-collect
- `just bao-login [args...]`: authenticate to OpenBao and install `/etc/bao.token`.
- `just bao-login-ststefa`: convenience wrapper for my usual LDAP login.
- `just refreshsecrets-system`: refresh system-scoped OpenBao secrets (sudo). If no `baoSystemSecrets` are configured for the current host, this is a no-op with an informational message.
- `just refreshsecrets-user`: refresh user-scoped OpenBao secrets (no sudo)
- `just refreshsecrets`: run both refresh targets
- `just rollback`: rollback one generation.

`just` resolves host OS from `.#hostInventory.<hostname>.os`.

## Design Intent

This layout prefers explicit structure over implicit magic:

- fewer hidden couplings,
- easier refactors,
- host portability via inventory,
- clean boundaries between foundation, platform, role, and user settings.

## Building blocks

This shows how the parts are connected together

```mermaid
graph LR
  flake["flake.nix"]
  hosts["inventory/hosts.nix"]

  flake --> hosts

  base["nix/{core,apps,shell}.nix + os/darwin/overlays.nix"]
  home_default["home/default.nix"]

  os_darwin["os/darwin/{system,apps,home}.nix"]
  os_linux["os/linux/{system,apps,home}.nix"]
  os_windows_home["os/windows/home.nix"]

  clients_darwin["clients/{hudson,bwpm}/{common,darwin,home}.nix"]
  clients_linux["clients/luna/{common,linux,home}.nix"]
  clients_windows_home["clients/winni/home.nix"]

  extra_darwin["os/darwin/system.nix -> merged sudoers fragments"]

  hosts -->|"darwin hosts"| os_darwin
  hosts -->|"linux hosts"| os_linux
  hosts -->|"windows hosts (HM only)"| os_windows_home

  hosts -->|"darwin hosts"| clients_darwin
  hosts -->|"linux hosts"| clients_linux
  hosts -->|"windows hosts (HM only)"| clients_windows_home

  hosts --> base
  hosts --> home_default

  os_darwin --> extra_darwin
```
