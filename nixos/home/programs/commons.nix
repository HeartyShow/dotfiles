{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Dotfiles
    stow

    # Utils
    bat
    btop
    dua
    entr
    eza
    fd
    fzf
    gcc
    gnumake
    just
    ripgrep
    unzip
    zoxide
    zip
  ];
}
