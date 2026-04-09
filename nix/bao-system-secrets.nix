{
  config,
  lib,
  os,
  pkgs,
  username,
  ...
}:
let
  common = import ./bao-secrets-common.nix { inherit lib pkgs os username; };
  cfg = config.ststefanix.baoSystemSecrets;
  isLinux = os == "linux";
  isDarwin = os == "darwin";

  defaultRuntimeDir = if isDarwin then "/private/var/run/secrets" else "/run/secrets";
  defaultSinkTokenFile = if isDarwin then "/private/var/run/bao/.token" else "/run/bao/.token";
  scopeOptions = common.mkScopeOptions {
    runtimeDirDefault = defaultRuntimeDir;
    pidFileDefault = "${defaultRuntimeDir}/bao-agent-system-secrets.pid";
    sinkTokenFileDefault = defaultSinkTokenFile;
    tokenFileDefault = "/etc/bao.token";
  };

  escapeSh = lib.escapeShellArg;
  pieces = common.mkAgentPieces {
    inherit cfg;
    name = "bao-agent-system-secrets";
    logPrefix = "bao-agent-system-secrets";
  };
  managedSystemDirs = pieces.managedDirs;
in
{
  options.ststefanix.baoSystemSecrets = {
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
            message = "OpenBao system secrets are currently supported only for linux and darwin.";
          }
        ];
      }

      (lib.optionalAttrs isLinux {
        systemd.tmpfiles.rules = map (d: "d ${d} 0750 root root -") managedSystemDirs;
        systemd.services.bao-agent-system-secrets = {
          description = "OpenBao Agent system secret renderer";
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
        system.activationScripts.baoAgentSystemSecrets.text = ''
          /bin/mkdir -p ${lib.concatMapStringsSep " " escapeSh managedSystemDirs}
          /usr/sbin/chown root:wheel ${lib.concatMapStringsSep " " escapeSh managedSystemDirs}
          /bin/chmod 0750 ${lib.concatMapStringsSep " " escapeSh managedSystemDirs}
        '';

        launchd.daemons.bao-agent-system-secrets = {
          command = "${pieces.runScript}";
          serviceConfig = {
            Label = "ststefanix.bao-agent-system-secrets";
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 3600;
            StandardOutPath = "/var/log/bao-agent-system-secrets.log";
            StandardErrorPath = "/var/log/bao-agent-system-secrets.log";
          };
        };
      })
    ]
  );
}
