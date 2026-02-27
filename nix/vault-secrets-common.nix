{
  lib,
  pkgs,
  os,
  username,
}:
let
  isDarwin = os == "darwin";
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  inherit homeDir;

  mkScopeOptions =
    {
      runtimeDirDefault,
      pidFileDefault,
      sinkTokenFileDefault,
      tokenFileDefault,
    }:
    {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.vault;
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "https://vault.heldenzeit.net";
      };

      logLevel = lib.mkOption {
        type = lib.types.enum [ "trace" "debug" "info" "warn" "err" ];
        default = "info";
      };

      runtimeDir = lib.mkOption {
        type = lib.types.str;
        default = runtimeDirDefault;
      };

      pidFile = lib.mkOption {
        type = lib.types.str;
        default = pidFileDefault;
      };

      sinkTokenFile = lib.mkOption {
        type = lib.types.str;
        default = sinkTokenFileDefault;
      };

      tokenFile = lib.mkOption {
        type = lib.types.str;
        default = tokenFileDefault;
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
      };

      secrets = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            vault_secret = lib.mkOption { type = lib.types.str; };
            vault_secret_key = lib.mkOption { type = lib.types.str; default = "value"; };
            destination = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
          };
        });
      };
    };

  mkAgentPieces =
    {
      cfg,
      name,
      logPrefix,
      extraManagedDirs ? [ ],
      destinationBase ? null,
    }:
    let
      escapeSh = lib.escapeShellArg;
      renderedSecretPaths = lib.mapAttrsToList (
        secretName: secret:
        "${cfg.runtimeDir}/${secretName}"
      ) cfg.secrets;
      linkDestinations = lib.mapAttrsToList (
        _secretName: secret:
        if secret.destination == null then
          null
        else if destinationBase == null then
          secret.destination
        else
          "${destinationBase}/${secret.destination}"
      ) (lib.filterAttrs (_: secret: secret.destination != null) cfg.secrets);
      linkPairs = lib.mapAttrsToList (
        secretName: secret:
        if secret.destination == null then
          null
        else
          {
            src = "${cfg.runtimeDir}/${secretName}";
            dst = secret.destination;
          }
      ) cfg.secrets;
      linkPairsFiltered = builtins.filter (x: x != null) linkPairs;
      secretDirs = lib.unique (map builtins.dirOf renderedSecretPaths);
      linkDirs = lib.unique (map builtins.dirOf linkDestinations);
      managedDirs = lib.unique ([ cfg.runtimeDir (builtins.dirOf cfg.sinkTokenFile) ] ++ extraManagedDirs);

      mkVaultTemplateBlock =
        secretName: secret:
        let
          renderedPath = "${cfg.runtimeDir}/${secretName}";
          resolvedDestination =
            if secret.destination == null then
              null
            else if destinationBase == null then
              secret.destination
            else
              "${destinationBase}/${secret.destination}";
        in
        ''
template {
  destination = "${renderedPath}"
  perms = "0400"
  contents = <<EOT
{{ with secret "${secret.vault_secret}" }}{{ index .Data.data "${secret.vault_secret_key}" }}{{ end }}
EOT
}
        '';

      templateBlocks = lib.concatStringsSep "\n" (lib.mapAttrsToList mkVaultTemplateBlock cfg.secrets);

      agentConfig = pkgs.writeText "${name}.hcl" ''
        pid_file = "${cfg.pidFile}"

        vault {
          address = "${cfg.address}"
        }

        auto_auth {
          method "token_file" {
            config = {
              token_file_path = "${cfg.tokenFile}"
            }
          }

          sink "file" {
            config = {
              path = "${cfg.sinkTokenFile}"
              mode = 0600
            }
          }
        }

        ${templateBlocks}

        ${cfg.extraConfig}
      '';

      envExports =
        lib.concatStringsSep "\n"
          (lib.mapAttrsToList (n: v: "export ${n}=${escapeSh v}") (cfg.environment // { VAULT_ADDR = cfg.address; }));

      runScript = pkgs.writeShellScript name ''
        set -eu
        ${envExports}
        ${lib.concatMapStringsSep "\n" (dir: "mkdir -p ${escapeSh dir}") (lib.unique (managedDirs ++ secretDirs ++ linkDirs))}
        ${lib.concatMapStringsSep "\n" (pair: "ln -sfn ${escapeSh pair.src} ${escapeSh pair.dst}") (
          map (
            pair:
            let
              dst =
                if destinationBase == null then
                  pair.dst
                else
                  "${destinationBase}/${pair.dst}";
            in
            pair // { inherit dst; }
          ) linkPairsFiltered
        )}
        echo "[${logPrefix}] starting vault agent (vault: ${cfg.address})"
        if [ ! -f ${escapeSh cfg.tokenFile} ]; then
          echo "[${logPrefix}] warning: token file not found at ${cfg.tokenFile}"
        fi
        echo "[${logPrefix}] rendering ${toString (builtins.length renderedSecretPaths)} secret file(s)"
        exec ${cfg.package}/bin/vault agent -log-level=${escapeSh cfg.logLevel} -config=${escapeSh agentConfig}
      '';
    in
    {
      hasSecrets = cfg.secrets != { };
      inherit runScript renderedSecretPaths managedDirs;
    };
}
