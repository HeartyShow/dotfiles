{ inputs, config, lib, pkgs, ... }: {

  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "alexandre.vialar";
    mutableTaps = true;
  };

  # Brew binaries on PATH for non-interactive shells too, like Rex popup commands
  environment.systemPath = [ "${config.homebrew.prefix}/bin" ];

  homebrew = {
    enable = true;
    greedyCasks = true;
    onActivation = {
      autoUpdate = true;
      upgrade = false;
      cleanup = "zap";
    };
    taps = builtins.attrNames config.nix-homebrew.taps ++ [ "crmne/tap" "gammons/tap" "tonisives/tap" ];
    casks = [
      "betterdisplay"
      "bruno"
      "docker-desktop"
      "figma"
      "ghostty"
      "logitech-g-hub"
      "losslesscut"
      "notion"
      "obsidian"
      "tonisives/tap/ovim"
      "raycast"
      "spotify"
      "crmne/tap/spotifast"
      "upscayl"
      "visual-studio-code"
      "vlc"
      "vorssaint"
      "slack"
      "gammons/tap/slk"
      "shottr"
      "zen"
    ];
  };
}
