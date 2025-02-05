{

  ##################################################################################################################
  #
  # This was derived by @ststefa from github.com:ryan4yin/nix-darwin-kickstarter.git/rich-demo
  #
  ##################################################################################################################

  description = "Nix for macOS configuration";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      #"https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  # This is the standard format for flake.nix. `inputs` are the dependencies of the flake,
  # Each item in `inputs` will be passed as a parameter to the `outputs` function after being pulled and built.
  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable"; # using unstable requires setting system.stateVersion, see modules/system.nix
    #nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";

    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  # The `outputs` function will return all the build results of the flake.
  # A flake can have many use cases and different types of outputs,
  # parameters in `outputs` are defined in `inputs` and can be referenced by their names.
  # However, `self` is an exception, this special parameter points to the `outputs` itself (self-reference)
  # The `@` syntax here is used to alias the attribute set of the inputs's parameter, making it convenient to use inside the function.
  outputs = inputs @ {
    self,
    nixpkgs,
    darwin,
    home-manager,
    ...
  }: let

    # This function allows the creation of multiple similar configs for different systems. The config is then chosen by specifying it in the nix invocation using the hostname. See Justfile. The variables allow to describe host-specfic features, like e.g. packages.
    mkDarwinConfig = { username, useremail, system, hostname }:
      let
        specialArgs =
          inputs
          // {
            inherit username useremail hostname;
          };
      in
     darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps_all.nix
        ./modules/apps_${hostname}.nix
        ./modules/host-users.nix

        # home manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users.${username} = import ./home;
          home-manager.backupFileExtension = "nixbak";
        }
      ];
    };

  in {
    # A separate Mac config for any system
    ## Main private Mac
    darwinConfigurations.hudson = mkDarwinConfig {
      username = "steinert";
      useremail = "ststefa@heldenzeit.net";
      system = "aarch64-darwin"; # aarch64-darwin or x86_64-darwin
      hostname = "hudson";
    };
    ## DB CICD Mac
    darwinConfigurations.bwpm-L454QQVWM2 = mkDarwinConfig {
      username = "stefansteinert";
      useremail = "stefan.steinert-extern@deutschebahn.com";
      system = "aarch64-darwin";
      hostname = "bwpm-L454QQVWM2";
    };

    # nix code formatter, not required for now and interfering
    #formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
