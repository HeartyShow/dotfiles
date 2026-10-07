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

  homebrew = {
    enable = true;
    greedyCasks = true;
    onActivation = {
      autoUpdate = true;
      upgrade = false;
      cleanup = "zap";
    };
    taps = builtins.attrNames config.nix-homebrew.taps;
    casks = [
      "betterdisplay"
      "bruno"
      "docker-desktop"
      "figma"
      "ghostty"
      "logitech-g-hub"
      "obsidian"
      "raycast"
      "spotify"
      "upscayl"
      "visual-studio-code"
      "vlc"
      "vorssaint"
      "slack"
      "shottr"
      "zen"
    ];
  };
}
