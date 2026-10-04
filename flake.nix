{
  description = "Nix configuration with host -> client -> os modularization";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      darwin,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      hosts = import ./inventory/hosts.nix;

      mkHostContext =
        hostName: host:
        host
        // {
          hostname = hostName;
          inventory = host // { hostname = hostName; };
        };

      mkDarwinConfig =
        hostName: host: extraModules:
        let
          ctx = mkHostContext hostName host;
          specialArgs = inputs // ctx;
        in
        darwin.lib.darwinSystem {
          inherit (ctx) system;
          inherit specialArgs;
          modules = [
            # Base: foundation shared across all targets
            ./nix/core.nix
            ./nix/apps.nix
            ./nix/sudoers.nix
            # OS axis: shared baseline + platform baseline
            ./nix/shell.nix
            ./nix/bao-secrets.nix
            ./os/darwin/overlays.nix
            (./os + "/${ctx.os}/system.nix")
            (./os + "/${ctx.os}/apps.nix")
            # Client axis: host role delta (os-specific)
            (./clients + "/${ctx.client}/${ctx.os}.nix")
            (./clients + "/${ctx.client}/secrets.nix")

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${ctx.username} = import ./home;
              home-manager.backupFileExtension = "nixbak";
            }
          ] ++ extraModules;
        };

      mkNixosConfig =
        hostName: host:
        let
          ctx = mkHostContext hostName host;
          specialArgs = inputs // ctx;
        in
        nixpkgs.lib.nixosSystem {
          inherit (ctx) system;
          inherit specialArgs;
          modules = [
            # Base: foundation shared across all targets
            ./nix/core.nix
            ./nix/apps.nix
            ./nix/sudoers.nix
            # OS axis: shared baseline + platform baseline
            ./nix/shell.nix
            ./nix/bao-secrets.nix
            (./os + "/${ctx.os}/system.nix")
            (./os + "/${ctx.os}/apps.nix")
            # Client axis: host role delta (os-specific)
            (./clients + "/${ctx.client}/${ctx.os}.nix")
            (./clients + "/${ctx.client}/secrets.nix")

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.users.${ctx.username} = import ./home;
              home-manager.backupFileExtension = "nixbak";
            }
          ];
        };

      mkWindowsWslHomeConfig =
        hostName: host:
        let
          ctx = mkHostContext hostName host;
          pkgs = import nixpkgs { inherit (ctx) system; };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = inputs // ctx;
          modules = [
            ./home
          ];
        };

      darwinHosts = lib.filterAttrs (_: host: host.os == "darwin") hosts;
      darwinHostsNoBrewUpdate = lib.mapAttrs' (
        hostName: host:
        lib.nameValuePair "${hostName}-nix-only" (
          mkDarwinConfig hostName host [
            {
              homebrew.enable = lib.mkForce false;
              homebrew.onActivation.autoUpdate = lib.mkForce false;
              homebrew.onActivation.upgrade = lib.mkForce false;
            }
          ]
        )
      ) darwinHosts;
      linuxHosts = lib.filterAttrs (_: host: host.os == "linux") hosts;
      windowsHosts = lib.filterAttrs (_: host: host.os == "windows") hosts;
    in
    {
      darwinConfigurations =
        (lib.mapAttrs (hostName: host: mkDarwinConfig hostName host [ ]) darwinHosts)
        // darwinHostsNoBrewUpdate;
      nixosConfigurations = lib.mapAttrs mkNixosConfig linuxHosts;
      homeConfigurations = lib.mapAttrs mkWindowsWslHomeConfig windowsHosts;

      hostInventory = hosts;
    };
}
