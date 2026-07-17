{ inputs, config, lib, pkgs, ... }: {

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "I584830";
    mutableTaps = true;
    taps = {
      # "haiperspace/hai" = inputs.homebrew-hai;
      "sap/homebrew-sapmachine" = inputs.homebrew-sapmachine;
      "cloudfoundry/homebrew-tap" = inputs.homebrew-cloudfoundry;
      "netbirdio/homebrew-tap" = inputs.homebrew-netbird;
    };
    trust = {
      taps = [
        "cloudfoundry/tap"
        "netbirdio/tap"
        "sap/sapmachine"
      ];
    };
  };

  homebrew = {
    enable = true;
    greedyCasks = true;
    onActivation = {
      upgrade = false;
      cleanup = "zap";
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "cf-cli@8"
    ];
    casks = [
      "alt-tab"
      "betterdisplay"
      "bruno"
      "docker-desktop"
      "figma"
      "ghostty"
      "hiddenbar"
      "keepingyouawake"
      "netbird-ui"
      "microsoft-auto-update"
      "microsoft-azure-storage-explorer"
      "microsoft-excel"
      "microsoft-onenote"
      "microsoft-outlook"
      "microsoft-powerpoint"
      "microsoft-teams"
      "microsoft-word"
      "obsidian"
      "onedrive"
      "sapmachine17-jdk"
      "sapmachine25-jdk"
      "raycast"
      {
        name = "spotify";
        args = { appdir = "~/Applications"; };
      }
      "visual-studio-code"
      "vlc"
      "scroll-reverser"
      "shottr"
      "zen"
    ];
  };
}
