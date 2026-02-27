{
  config,
  lib,
  os,
  pkgs,
  username,
  ...
}:
let
  common = import ./vault-secrets-common.nix { inherit lib pkgs os username; };
  cfg = config.ststefanix.vaultSystemSecrets;
  isLinux = os == "linux";
  isDarwin = os == "darwin";

  defaultRuntimeDir = if isDarwin then "/private/var/run/secrets" else "/run/secrets";
  defaultSinkTokenFile = if isDarwin then "/private/var/run/vault/.token" else "/run/vault/.token";
  scopeOptions = common.mkScopeOptions {
    runtimeDirDefault = defaultRuntimeDir;
    pidFileDefault = "${defaultRuntimeDir}/vault-agent-system-secrets.pid";
    sinkTokenFileDefault = defaultSinkTokenFile;
    tokenFileDefault = "/etc/vault.token";
  };

  escapeSh = lib.escapeShellArg;
  pieces = common.mkAgentPieces {
    inherit cfg;
    name = "vault-agent-system-secrets";
    logPrefix = "vault-agent-system-secrets";
  };
  managedSystemDirs = pieces.managedDirs;
in
{
  options.ststefanix.vaultSystemSecrets = {
    inherit (scopeOptions)
      package
      address
      logLevel
      runtimeDir
      pidFile
      sinkTokenFile
      tokenFile
      environment
      extraConfig
      secrets
      ;
  };

  config = lib.mkIf pieces.hasSecrets (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = isLinux || isDarwin;
            message = "vaultSystemSecrets is currently supported only for linux and darwin.";
          }
        ];
      }

      (lib.optionalAttrs isLinux {
        systemd.tmpfiles.rules = map (d: "d ${d} 0750 root root -") managedSystemDirs;
        systemd.services.vault-agent-system-secrets = {
          description = "Vault Agent system secret renderer";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pieces.runScript}";
            Restart = "always";
            RestartSec = "1h";
          };
        };
      })

      (lib.optionalAttrs isDarwin {
        system.activationScripts.vaultAgentSystemSecrets.text = ''
          /bin/mkdir -p ${lib.concatMapStringsSep " " escapeSh managedSystemDirs}
          /usr/sbin/chown root:wheel ${lib.concatMapStringsSep " " escapeSh managedSystemDirs}
          /bin/chmod 0750 ${lib.concatMapStringsSep " " escapeSh managedSystemDirs}
        '';

        launchd.daemons.vault-agent-system-secrets = {
          command = "${pieces.runScript}";
          serviceConfig = {
            Label = "ststefanix.vault-agent-system-secrets";
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 3600;
            StandardOutPath = "/var/log/vault-agent-system-secrets.log";
            StandardErrorPath = "/var/log/vault-agent-system-secrets.log";
          };
        };
      })
    ]
  );
}
