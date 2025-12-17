{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Dotfiles
    stow

    # Utils
    bat
    dua
    entr
    eza
    fd
    fzf
    gcc
    gnumake
    ripgrep
    unzip
    zoxide
    zip
  ];

  # home.file.".dotfiles" = {
  #     source = pkgs.runCommand "clone-dotfiles" {} ''
  #     mkdir -p $out
  #     git clone https://github.com/HeartyShow/dotfiles.git $out
  # '';
  # };
}
