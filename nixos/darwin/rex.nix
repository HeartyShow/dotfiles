{ pkgs, ... }: {

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  system.defaults.CustomUserPreferences."com.superlogical.rex" = {
    "rex.agents.names-sessions" = false;
    "rex.client.remoteControl" = true;

    "Workspace.activePaneBorderColor" = "accent";
    "Workspace.activePaneBorderOpacity" = 1.0;
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
