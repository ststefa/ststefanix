{
  lib,
  pkgs,
  system,
  username,
}:
let
  hostPlatform = lib.systems.elaborate { inherit system; };
  isDarwin = hostPlatform.parsed.kernel.name == "darwin";
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  inherit homeDir;

  mkScopeOptions =
    {
      tokenFileDefault,
    }:
    {
      address = lib.mkOption {
        type = lib.types.str;
        default = "https://bao.heldenzeit.net";
      };

      logLevel = lib.mkOption {
        type = lib.types.enum [ "trace" "debug" "info" "warn" "err" ];
        default = "info";
      };

      # OpenBao polls static KV secrets on an interval. This default keeps
      # propagation reasonably quick without hammering the server.
      staticSecretRenderInterval = lib.mkOption {
        type = lib.types.str;
        default = "3m";
      };

      tokenFile = lib.mkOption {
        type = lib.types.str;
        default = tokenFileDefault;
      };

      secrets = lib.mkOption {
        default = { };
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            bao_secret = lib.mkOption { type = lib.types.str; };
            bao_secret_key = lib.mkOption { type = lib.types.str; default = "value"; };
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
      runtimeDir,
      pidFile,
      sinkTokenFile,
      extraManagedDirs ? [ ],
      destinationBase ? null,
    }:
    let
      escapeSh = lib.escapeShellArg;
      renderedSecretPaths = lib.mapAttrsToList (
        secretName: secret:
        "${runtimeDir}/${secretName}"
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
            src = "${runtimeDir}/${secretName}";
            dst = secret.destination;
          }
      ) cfg.secrets;
      linkPairsFiltered = builtins.filter (x: x != null) linkPairs;
      secretDirs = lib.unique (map builtins.dirOf renderedSecretPaths);
      linkDirs = lib.unique (map builtins.dirOf linkDestinations);
      managedDirs = lib.unique ([ runtimeDir (builtins.dirOf sinkTokenFile) ] ++ extraManagedDirs);

      mkBaoTemplateBlock =
        secretName: secret:
        let
          renderedPath = "${runtimeDir}/${secretName}";
        in
        ''
template {
  destination = "${renderedPath}"
  perms = "0400"
  contents = <<EOT
{{ with secret "${secret.bao_secret}" }}{{ index .Data.data "${secret.bao_secret_key}" }}{{ end }}
EOT
}
        '';

      templateBlocks = lib.concatStringsSep "\n" (lib.mapAttrsToList mkBaoTemplateBlock cfg.secrets);

      agentConfig = pkgs.writeText "${name}.hcl" ''
        pid_file = "${pidFile}"

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
              path = "${sinkTokenFile}"
              mode = 0600
            }
          }
        }

        # This controls how often non-leased secrets such as KV v2 are re-read.
        template_config {
          static_secret_render_interval = "${cfg.staticSecretRenderInterval}"
        }

        ${templateBlocks}
      '';

      envExports =
        lib.concatStringsSep "\n"
          (
            lib.mapAttrsToList
              (n: v: "export ${n}=${escapeSh v}")
              {
                BAO_ADDR = cfg.address;
                VAULT_ADDR = cfg.address;
              }
          );

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
        echo "[${logPrefix}] starting OpenBao agent (address: ${cfg.address})"
        if [ ! -f ${escapeSh cfg.tokenFile} ]; then
          echo "[${logPrefix}] warning: token file not found at ${cfg.tokenFile}"
        fi
        echo "[${logPrefix}] rendering ${toString (builtins.length renderedSecretPaths)} secret file(s)"
        exec ${pkgs.openbao}/bin/bao agent -log-level=${escapeSh cfg.logLevel} -config=${escapeSh agentConfig}
      '';
    in
    {
      hasSecrets = cfg.secrets != { };
      inherit runScript renderedSecretPaths managedDirs;
    };
}
