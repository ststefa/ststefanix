{
  pkgs,
  username,
  config,
  ...
}:
#  Darwin system configuration
#
#  See https://daiderd.com/nix-darwin/manual/index.html#sec-options
{
  system = {
    # Required since 25.05 because all activation now takes place as root by default.
    primaryUser = username;

    stateVersion = 4;

    #  Incomplete list of macOS `defaults` commands: https://macos-defaults.com
    defaults = {
      dock = {
        autohide = false;
        show-recents = false;
        wvous-tl-corner = 1;
        wvous-tr-corner = 6;
        wvous-bl-corner = 1;
        wvous-br-corner = 14;
      };

      finder = {
        _FXEnableColumnAutoSizing = true;
        _FXShowPosixPathInTitle = false;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        QuitMenuItem = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
        ShowRemovableMediaOnDesktop = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        "com.apple.sound.beep.feedback" = 1;
        "com.apple.swipescrolldirection" = true;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
      };

      CustomUserPreferences = {
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.AppleMultitouchTrackpad" = {
          Clicking = 1;
        };
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.spaces" = {
          "spans-displays" = 0;
        };
        "com.apple.WindowManager" = {
          EnableStandardClickToShowDesktop = 0;
          HideDesktop = 0;
          StageManagerHideWidgets = 0;
          StandardHideDesktopIcons = 0;
          StandardHideWidgets = 0;
        };
        "com.apple.ImageCapture".disableHotPlug = true;
      };

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };
    };

    keyboard = { };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome
      nerd-fonts.bigblue-terminal
      nerd-fonts.fira-code
      nerd-fonts.geist-mono
      nerd-fonts.iosevka
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
  };

  # Create a helpful file to document installed packages and their versions
  environment.etc."nix-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
    in
    builtins.concatStringsSep "\n" sortedUnique;

}
