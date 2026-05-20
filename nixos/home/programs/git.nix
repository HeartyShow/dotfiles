{
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    delta
    gh
    gh-dash
    git
    git-credential-manager
    lazygit
  ];
}
