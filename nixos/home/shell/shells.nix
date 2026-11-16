{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    coreutils
    zsh
    sheldon
    oh-my-posh

    tmux
    tmuxinator
    sesh
    worktrunk
  ];
}
