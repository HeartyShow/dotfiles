{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Dotfiles
    stow

    # Utils
    bat
    zoxide
    eza
    fzf
    ripgrep
    fd
    gcc
    gnumake
    zip
    unzip

    # Docker
    docker
  ];

  programs.neovim = {
    enable = true;
  };
}
