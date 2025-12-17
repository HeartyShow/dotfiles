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
    dua
  ];

  # home.file.".dotfiles" = {
  #     source = pkgs.runCommand "clone-dotfiles" {} ''
  #     mkdir -p $out
  #     git clone https://github.com/HeartyShow/dotfiles.git $out
  # '';
  # };
}
