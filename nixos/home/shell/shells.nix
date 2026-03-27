{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    zsh
    sheldon
    oh-my-posh

    tmux
    tmuxinator
    sesh
    worktrunk
  ];
}
