{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    delta
    gh
    git
    git-credential-manager
    lazygit
  ];
}
