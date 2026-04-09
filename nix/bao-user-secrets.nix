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
  cfg = config.ststefanix.baoUserSecrets;
  isLinux = os == "linux";
  isDarwin = os == "darwin";
  homeDir = common.homeDir;

  isSafeRelativePath =
    p:
    p != ""
    && !(lib.hasPrefix "/" p)
    && builtins.all (seg: seg != "" && seg != "." && seg != "..") (lib.splitString "/" p);

  defaultRuntimeDir = "${homeDir}/.local/run/secrets";
  defaultSinkTokenFile = "${homeDir}/.local/state/bao/.token";
  scopeOptions = common.mkScopeOptions {
    runtimeDirDefault = defaultRuntimeDir;
    pidFileDefault = "${defaultRuntimeDir}/bao-agent-user-secrets.pid";
    sinkTokenFileDefault = defaultSinkTokenFile;
    tokenFileDefault = "${homeDir}/.vault-token";
  };
  pieces = common.mkAgentPieces {
    inherit cfg;
    name = "bao-agent-user-secrets";
    logPrefix = "bao-agent-user-secrets";
    extraManagedDirs = lib.optional isDarwin "${homeDir}/Library/Logs";
    destinationBase = homeDir;
  };
  hasSecrets = pieces.hasSecrets;
in
{
  options.ststefanix.baoUserSecrets = {
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

  config = lib.mkIf hasSecrets (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = isLinux || isDarwin;
            message = "OpenBao user secrets are currently supported only for linux and darwin.";
          }
          {
            assertion = builtins.all (
              secret:
              secret.destination == null || isSafeRelativePath secret.destination
            ) (builtins.attrValues cfg.secrets);
            message = "OpenBao user secret destinations must be safe paths relative to $HOME (e.g. .config/sops/age/keys.txt).";
          }
        ];
      }

      (lib.optionalAttrs isLinux {
        # User unit starts with the user manager (typically after login unless linger is enabled).
        systemd.user.services.bao-agent-user-secrets = {
          description = "OpenBao Agent user secret renderer";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pieces.runScript}";
            Restart = "always";
            RestartSec = "1h";
          };
        };
      })

      (lib.optionalAttrs isDarwin {
        launchd.user.agents.bao-agent-user-secrets = {
          command = "${pieces.runScript}";
          serviceConfig = {
            Label = "ststefanix.bao-agent-user-secrets";
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 3600;
            StandardOutPath = "${homeDir}/Library/Logs/bao-agent-user-secrets.log";
            StandardErrorPath = "${homeDir}/Library/Logs/bao-agent-user-secrets.log";
          };
        };
      })
    ]
  );
}
