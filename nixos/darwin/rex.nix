{ pkgs, ... }:
let
  rexurrect = pkgs.rustPlatform.buildRustPackage rec {
    pname = "rexurrect";
    version = "0.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "cemcatik";
      repo = "rexurrect";
      rev = "v${version}";
      hash = "sha256-YNXqF6I/6KIESo07JHiONCD5PlgR6my9C/tvA++Spco=";
    };
    cargoHash = "sha256-Da8mPDmYtHkzG5QW0t8W3N1KNp1WduSy3oBcQ/FAs5A=";
    doCheck = false;
    postInstall = "install -Dm644 rexurrect.plugin.zsh $out/share/rexurrect/rexurrect.plugin.zsh";
  };
in {

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  environment.systemPackages = [ rexurrect ];

  launchd.user.agents.rexurrect-autosave.serviceConfig = {
    # rexurrect calls `rex`, which launchd's default PATH doesn't have
    ProgramArguments = [
      "/bin/sh"
      "-c"
      ''PATH="$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS:$PATH" exec ${rexurrect}/bin/rexurrect save''
    ];
    StartInterval = 900;
  };

  system.defaults.CustomUserPreferences."com.superlogical.rex" = {
    "rex.agents.names-sessions" = false;
    "rex.client.remoteControl" = true;
    "rex.developer-mode-enabled" = true;
    RexAppUpdateChannel = "snapshot";
    "Workspace.activePaneBorderColor" = "accent";
    "Workspace.activePaneBorderOpacity" = 0.8;
    "Workspace.activePaneBorderTransition" = "fade";
    "Workspace.allowsTerminalNotifications" = true;
    "Workspace.animationStyle" = "snappy";
    "Workspace.appIcon" = "default";
    "Workspace.balancesSplitsOnCreation" = true;
    "Workspace.darkThemeID" = "custom-02E754FA-6933-471C-AE0E-8A4D34066EF8";
    "Workspace.focusFollowsMouse" = false;
    "Workspace.inactivePaneFadeMode" = "both";
    "Workspace.interfaceStyle" = "useTheme";
    "Workspace.lightThemeID" = "merino-light";
    "Workspace.notificationPosition" = "top-right";
    "Workspace.paneDensity" = "compact";
    "Workspace.preservesWindowWidthOnSidebarToggle" = true;
    "Workspace.shellIconTheme" = "themed";
    "Workspace.showsActivePaneBorder" = false;
    "Workspace.showsIdleProgramsInActivity" = false;
    "Workspace.showsPaneHeaders" = false;
    "Workspace.showsProcessesInActivity" = true;
    "Workspace.sidebarPosition" = "left";
    "Workspace.sidebarShowsActivity" = false;
    "Workspace.tabBarEdge" = "bottom";
    "Workspace.tabIconColorMode" = "always";
    "Workspace.tabIconCount" = 3;
    "Workspace.tabIconTintMode" = "off";
    "Workspace.tabStyle" = "vertical";
    "Workspace.terminalCopyOnSelect" = true;
    "Workspace.terminalCursorBlinkIntervalMilliseconds" = 500;
    "Workspace.terminalCursorBlinkUsesCustomInterval" = false;
    "Workspace.terminalCursorStyle" = "block";
    "Workspace.terminalCustomSchemeLinks" = "ask";
    "Workspace.terminalFontName" = "JetBrainsMono Nerd Font Mono";
    "Workspace.terminalFontPointSize" = 13.0;
    "Workspace.terminalFontSmoothing" = false;
    "Workspace.terminalPaddingColor" = "extend";
    "Workspace.terminalPaddingX" = 5.0;
    "Workspace.terminalPaddingY" = 0.0;
    "Workspace.terminalSelectionRoundedCorners" = true;
    "Workspace.terminalSmoothScrolling" = false;
    "Workspace.tintsPanesWithProgramBackground" = true;
    "Workspace.usesStandardInactiveWindowPaneStyles" = false;
  };
}
