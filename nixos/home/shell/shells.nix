{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    zsh
    oh-my-posh
    tmux
    tmuxinator
  ];

  # programs = {
  #   zsh.enable = true;
  #   oh-my-posh.enable = true;
  #   tmux.enable = true;
  #   tmuxinator.enable = true;
  # };
}
