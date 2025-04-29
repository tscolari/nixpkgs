{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.vanta-agent;
in
{
  options = {
    services.vanta-agent = {
      enable = lib.mkEnableOption "Vanta Agent";
      package = lib.mkPackageOption pkgs "vanta-agent" { };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    systemd.packages = [ cfg.package ];

    systemd.tmpfiles.rules = [
      "d /var/vanta/osquery.db"
      "L /var/vanta/cert.pem - - - - ${cfg.package}/var/vanta/cert.pem"
      "L /var/vanta/ - - - - /var/lib/vanta"
    ];

    systemd.services.vanta = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        PrivateTmp = true;
        NoNewPrivileges = true;
        RestrictNamespaces = true;
        RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
        CapabilityBoundingSet = "CAP_DAC_OVERRIDE CAP_SYS_ADMIN CAP_WRITE CAP_CREATE CAP_FOWNER CAP_CHOWN";
        ProtectSystem = "strict";
        PrivateDevices = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = false;
        ProtectKernelTunables = true;
        ProtectProc = "default";
        ProtectHome = "read-only";
        SystemCallArchitectures = "native";
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
        MemoryDenyWriteExecute = true;
        ProcSubset = "all";
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        ReadWritePaths = [
          "/var/vanta"
          "/var/vanta/log"
          "/var/vanta/osquery.db"
        ];

        # vanta expects to find its many files in /var/vanta, but it also expects to be able to
        # write other files (and a log directory) in the same directory
        StateDirectory = "vanta";
        RuntimeDirectory = "vanta/log";
        BindReadOnlyPaths = [
          "${cfg.package}/var/vanta/launcher:/var/vanta/launcher:norbind"
          "${cfg.package}/var/vanta/metalauncher:/var/vanta/metalauncher:norbind"
          "${cfg.package}/var/vanta/vanta-cli:/var/vanta/vanta-cli:norbind"
          "${cfg.package}/var/vanta/osqueryd:/var/vanta/osqueryd:norbind"
          "${cfg.package}/var/vanta/osquery-vanta.ext:/var/vanta/osquery-vanta.ext:norbind"
        ];
      };
    };
  };
}
